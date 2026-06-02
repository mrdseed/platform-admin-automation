# Key Vault Module

RBAC-enabled Azure Key Vault with optional private endpoint and diagnostic settings. Access policies are not used.

## Usage

```hcl
module "key_vault_prod" {
  source = "../../modules/key-vault"

  name                = "kv-platform-prod-eus2-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  purge_protection_enabled      = true
  public_network_access_enabled = false

  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-pe-prod-eus2-001"]
  private_dns_zone_ids         = [data.azurerm_private_dns_zone.kv.id]
  log_analytics_workspace_id   = data.azurerm_log_analytics_workspace.platform.id

  rbac_assignments = {
    pipeline = {
      principal_id         = var.pipeline_object_id
      role_definition_name = "Key Vault Secrets Officer"
      description          = "Terraform pipeline secret management"
    }
    app_identity = {
      principal_id         = module.app_identity.principal_id
      role_definition_name = "Key Vault Secrets User"
      description          = "Application runtime secret access"
    }
  }

  tags = module.rg.tags
}
```

## Required RBAC for Pipeline

- `Contributor` on resource group
- `User Access Administrator` or pre-created role assignments for vault RBAC
