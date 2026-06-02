# Key Vault Module

RBAC-enabled Key Vault with diagnostic settings. Private endpoints and role assignments are composed via [private-endpoint](../private-endpoint/) and [role-assignment](../role-assignment/) modules.

## Usage

```hcl
module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-platform-dev-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  tenant_id           = var.tenant_id

  public_network_access_enabled = false
  purge_protection_enabled      = var.environment == "prod"
  log_analytics_workspace_id    = module.log_analytics.id

  tags = local.platform_tags
}

module "pe_key_vault" {
  source = "../../modules/private-endpoint"
  # ...
}

module "kv_rbac" {
  source = "../../modules/role-assignment"
  # ...
}
```

## Security

- `enable_rbac_authorization = true` — access policies not used
- `public_network_access_enabled = false` by default

## Required RBAC

`PlatformDeploy-KeyVault` custom role.
