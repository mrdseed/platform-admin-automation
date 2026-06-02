# Resource Group Module

Creates an Azure resource group with mandatory platform tags and optional CanNotDelete management lock.

## Usage

```hcl
module "rg_spoke_prod" {
  source = "../../modules/resource-group"

  name             = "rg-platform-app-prod-eus2-001"
  location         = "eastus2"
  environment      = "prod"
  cost_center      = "CC-1042"
  owner_email      = "platform-team@example.com"
  application_name = "platform-app"
  data_classification = "confidential"

  enable_management_lock = true
}
```

## Required RBAC

Pipeline identity requires `Contributor` on subscription or target scope to create resource groups.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Resource group name | string | — | yes |
| location | Azure region | string | `eastus2` | no |
| environment | Environment tag value | string | — | yes |
| cost_center | Cost center code | string | — | yes |
| owner_email | Owner contact | string | — | yes |
| application_name | Application identifier | string | — | yes |
| data_classification | Data classification tag | string | `internal` | no |
| enable_management_lock | Apply delete lock | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource group ID |
| name | Resource group name |
| location | Region |
| tags | Applied tags map |
