# Managed Identity Module

User-assigned managed identity for workload access to Key Vault, Storage, and other data-plane resources.

## Usage

```hcl
module "app_identity" {
  source = "../../modules/managed-identity"

  name                = "id-platform-app-prod-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  tags                = module.resource_group.tags
}

module "rbac" {
  source = "../../modules/role-assignment"

  assignments = {
    kv = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
    }
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Identity ARM ID — attach to VM |
| principal_id | Use for role assignments |
| client_id | Application runtime reference |

## Required RBAC

`PlatformDeploy-Compute` for identity creation; data-plane roles via role-assignment module.
