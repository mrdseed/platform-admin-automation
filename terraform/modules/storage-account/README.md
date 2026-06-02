# Storage Account Module

Private-first storage account with blob soft delete, optional SFTP, and diagnostic settings.

## Security Defaults

| Setting | Default |
|---------|---------|
| `public_network_access_enabled` | `false` |
| `allow_nested_items_to_be_public` | `false` |
| `shared_access_key_enabled` | `false` |
| `min_tls_version` | `TLS1_2` |
| Network rules | Deny when public access disabled |

## Usage

```hcl
module "storage" {
  source = "../../modules/storage-account"

  name                = "stplatformprod001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  tags                = module.resource_group.tags

  log_analytics_workspace_id = module.log_analytics.id
}

module "pe_storage" {
  source = "../../modules/private-endpoint"
  # ...
}
```

## Required RBAC

`PlatformDeploy-Storage` custom role.
