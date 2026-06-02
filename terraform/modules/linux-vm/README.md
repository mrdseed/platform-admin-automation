# Linux VM Module

Standardized Linux virtual machine with Trusted Launch, SSH key authentication, managed identity attachment, and Azure Monitor Agent.

**No public IP** — this module creates private NICs only. Remote access is via Azure Bastion or approved private paths.

## Usage

```hcl
module "vm_app_prod" {
  source = "../../modules/linux-vm"

  name                = "vm-app-prod-eus2-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  subnet_id           = module.vnet.subnet_ids["snet-app-prod-eus2-001"]

  vm_size        = "Standard_D4s_v5"
  ssh_public_key = var.admin_ssh_public_key

  user_assigned_identity_ids = [azurerm_user_assigned_identity.app.id]
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.platform.id

  cloud_init_data = file("${path.module}/cloud-init.yaml.tpl")

  tags = module.rg.tags
}
```

## Required Pipeline Permissions

Assign [PlatformDeploy-Compute](../../security/custom-rbac/deployment-sp-compute-role.json) — not Contributor:

| Permission | Why |
|------------|-----|
| `Microsoft.Compute/virtualMachines/write` | Create/update VM |
| `Microsoft.Network/networkInterfaces/join/action` | Attach private NIC |
| `Microsoft.ManagedIdentity/userAssignedIdentities/assign/action` | Attach workload MI |

Explicitly **excluded**: `Microsoft.Network/publicIPAddresses/*`

## Security Notes

- No password authentication; SSH keys only
- No public IP created or attachable via this module
- Access via Bastion in hub VNet — see [examples/no-public-ip/](../../examples/no-public-ip/)
- Trusted Launch enabled by default (Secure Boot + vTPM)
- Apply Ansible hardening before image capture — see [ansible/](../../ansible/)

## Post-Deploy Hardening

For golden images, run Ansible playbooks after base deploy:

```bash
ansible-playbook -i inventory/build.yml ansible/playbooks/baseline-hardening.yml
ansible-playbook -i inventory/build.yml ansible/playbooks/validate-image.yml
```
