# Role Assignment Module

Creates Azure RBAC assignments with validation that blocks Owner, Contributor, and User Access Administrator.

## Usage

```hcl
module "role_assignments" {
  source = "../../modules/role-assignment"

  assignments = {
    app_secrets = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
      description          = "Runtime secret access"
    }
    app_blobs = {
      scope                = module.storage_account.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = module.app_identity.principal_id
    }
  }
}
```

Pipeline deploy principals should use custom roles from [security/custom-rbac/](../../../security/custom-rbac/) at deploy time — not via this module with broad roles.

## Outputs

| Name | Description |
|------|-------------|
| ids | Map of assignment key to ARM ID |
| principal_ids | Distinct principals receiving roles |
