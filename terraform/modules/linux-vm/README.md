# Linux VM Module

Standardized Linux virtual machine with Trusted Launch, SSH key authentication, managed identity attachment, and Azure Monitor Agent.

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

## Security Notes

- No password authentication; SSH keys only
- No public IP created by this module — access via Bastion
- Trusted Launch enabled by default (Secure Boot + vTPM)
