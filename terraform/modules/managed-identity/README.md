# Managed Identity Module

User-assigned managed identity for workload and pipeline resource access.

## Usage

```hcl
module "app_identity" {
  source = "../../modules/managed-identity"

  name                = "id-platform-app-dev-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  tags                = local.platform_tags
}
```

Assign roles via [role-assignment](../role-assignment/) module — avoid Contributor.
