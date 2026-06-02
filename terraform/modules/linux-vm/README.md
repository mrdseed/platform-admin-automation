# Linux VM Module

Standardized Linux VM with **private IP only** — no public IP resource exists in this module.

## Security Defaults

| Control | Default |
|---------|---------|
| Public IP | Not supported |
| Password auth | Disabled |
| Trusted Launch | Enabled (Secure Boot + vTPM) |
| SSH | Key-based only |

## Usage

```hcl
module "linux_vm" {
  source = "../../modules/linux-vm"

  name                = "vm-app-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.subnet_app.id
  tags                = module.resource_group.tags

  vm_size        = "Standard_D4s_v5"
  ssh_public_key = var.ssh_public_key

  user_assigned_identity_ids    = [module.app_identity.id]
  log_analytics_workspace_guid  = module.log_analytics.workspace_id
}
```

Access the VM via **Azure Bastion** or a private jump host — never via public IP.

## Required RBAC

`PlatformDeploy-Compute` custom role.

## Outputs

| Name | Description |
|------|-------------|
| private_ip_address | Private NIC IP |
| id | VM ARM ID |
| network_interface_id | NIC ARM ID |
