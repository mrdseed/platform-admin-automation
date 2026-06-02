# Resource Group Module

Creates an Azure resource group with mandatory platform tags and an optional CanNotDelete management lock.

## Design Notes

- Tags are built inside the module so every downstream resource inherits consistent metadata via `module.resource_group.tags`.
- Production resource groups should set `enable_management_lock = true`.
- Pipeline principals need `PlatformDeploy-*` custom roles — not Contributor.

## Usage

```hcl
module "resource_group" {
  source = "../../modules/resource-group"

  name             = "rg-platform-app-prod-eus2-001"
  location         = "eastus2"
  environment      = "prod"
  cost_center      = "CC-1042"
  owner_email      = "platform-team@example.com"
  application_name = "platform-app"
  data_classification = "confidential"

  enable_management_lock = true

  additional_tags = {
    PatchGroup = "linux-prod-monthly"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Resource group name (`rg-{workload}-{env}-{region}-{seq}`) | string | — | yes |
| location | Azure region | string | `eastus2` | no |
| environment | Environment tag value | string | — | yes |
| cost_center | Cost center code | string | — | yes |
| owner_email | Owner contact email | string | — | yes |
| application_name | Application identifier | string | — | yes |
| data_classification | Data classification tag | string | `internal` | no |
| additional_tags | Extra tags merged with mandatory set | map(string) | `{}` | no |
| enable_management_lock | Apply CanNotDelete lock | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource group ARM ID |
| name | Resource group name |
| location | Region |
| tags | Platform tag map for child modules |
| management_lock_id | Lock ID if enabled |

## Required RBAC

`Microsoft.Resources/subscriptions/resourceGroups/write` via scoped custom role.
