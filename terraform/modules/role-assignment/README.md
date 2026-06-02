# Role Assignment Module

Creates Azure RBAC role assignments with validation blocking Owner, Contributor, and User Access Administrator.

## Usage

```hcl
module "rbac" {
  source = "../../modules/role-assignment"

  assignments = {
    app_kv_secrets = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
      description          = "Application runtime secret access"
    }
    app_storage_blob = {
      scope                = module.storage.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = module.app_identity.principal_id
    }
  }
}
```

Use custom deploy roles from [security/custom-rbac/](../../../security/custom-rbac/) for pipeline principals.
