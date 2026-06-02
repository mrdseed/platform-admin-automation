# Key Vault Module

RBAC-enabled Key Vault with audit diagnostics. Private access and role assignments are composed using sibling modules.

## Security Defaults

- `enable_rbac_authorization = true` (not configurable — access policies are not used)
- `public_network_access_enabled = false` by default
- `purge_protection_enabled = true` by default (override in dev only)

## Usage

```hcl
module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-platform-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  tenant_id           = var.tenant_id
  tags                = module.resource_group.tags

  log_analytics_workspace_id = module.log_analytics.id
}

module "pe_key_vault" {
  source = "../../modules/private-endpoint"
  # subnet_id, private_connection_resource_id = module.key_vault.id
}

module "kv_rbac" {
  source = "../../modules/role-assignment"
  # Key Vault Secrets User for workload MI
}
```

## Required RBAC

`PlatformDeploy-KeyVault` for vault resource; `Key Vault Secrets User` for runtime identities via role-assignment module.
