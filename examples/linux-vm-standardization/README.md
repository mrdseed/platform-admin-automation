# Linux VM Standardization Example

Enterprise Linux VM deployment pattern with Trusted Launch, cloud-init hardening, Azure Monitor Agent, and managed identity.

## Standard Configuration

| Setting | Value |
|---------|-------|
| OS | Ubuntu 22.04 LTS Gen2 |
| Auth | SSH key only — no passwords |
| Boot | Secure Boot + vTPM (Trusted Launch) |
| Access | Azure Bastion — no public IP |
| Patching | Azure Update Manager — monthly maintenance config |
| Monitoring | Azure Monitor Agent + Dependency Agent |
| Identity | User-assigned managed identity per application |

## Usage

```hcl
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-platform-app-prod-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
}

module "app_server" {
  source = "../../terraform/modules/linux-vm"

  name                = "vm-app-prod-eus2-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  subnet_id           = module.vnet.subnet_ids["snet-app-prod-eus2-001"]

  vm_size        = "Standard_D4s_v5"
  ssh_public_key = var.admin_ssh_public_key

  user_assigned_identity_ids = [azurerm_user_assigned_identity.app.id]
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.platform.id

  cloud_init_data = templatefile("${path.module}/cloud-init.yaml", {
    log_analytics_id = data.azurerm_log_analytics_workspace.platform.workspace_id
  })

  tags = merge(module.rg.tags, {
    PatchGroup = "linux-prod-monthly"
  })
}
```

## Cloud-Init Baseline

The module includes `cloud-init.yaml.tpl` with:

- Package updates on first boot
- SSH hardening (`PasswordAuthentication no`, `PermitRootLogin no`)
- fail2ban installation
- AIDE integrity baseline initialization

Production cloud-init payloads are stored in `stplatformassets001` and referenced by hash — not embedded with secrets.

## Maintenance Configuration

Assign VMs to platform maintenance configuration:

```hcl
resource "azurerm_maintenance_assignment_virtual_machine" "app" {
  location                     = module.rg.location
  maintenance_configuration_id = data.azurerm_maintenance_configuration.linux_monthly.id
  virtual_machine_id           = module.app_server.id
}
```

## Compliance Alignment

- Azure Policy: `Deploy-Linux-AMA`
- CIS Ubuntu 22.04 L1 — partial automation via cloud-init; remainder via Azure Guest Configuration (planned Q3 2026)

## Related Runbook

[Linux VM Patching Failure](../../docs/runbook.md#7-runbook-linux-vm-patching-failure)
