# Storage Account Module

Private-first storage account with public blob access disabled by default.

## Usage

```hcl
module "storage" {
  source = "../../modules/storage-account"

  name                = "stplatformdev001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.platform_tags
}
```

Pair with [private-endpoint](../private-endpoint/) for private access.

## Security Defaults

- `allow_nested_items_to_be_public = false`
- `public_network_access_enabled = false`
- No public IP or anonymous blob access

## Required RBAC

`PlatformDeploy-Storage` custom role.
