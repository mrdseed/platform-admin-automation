# Resource Group Module

Creates an Azure resource group with **seven mandatory platform tags** and an optional CanNotDelete management lock.

## Mandatory Tags Applied

| Tag Key | Variable |
|---------|----------|
| `environment` | `var.environment` |
| `application` | `var.application_name` |
| `owner` | `var.owner_email` |
| `cost-center` | `var.cost_center` |
| `data-classification` | `var.data_classification` |
| `managed-by` | `terraform` (fixed) |
| `business-unit` | `var.business_unit` |

Pass `module.resource_group.tags` to all downstream modules.

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
  business_unit    = "engineering"
  data_classification = "confidential"

  enable_management_lock = true
}
```

## Outputs

| Name | Description |
|------|-------------|
| tags | Tag map for all child modules |
| id | Resource group ARM ID |
| name | Resource group name |

## Governance

- [Platform Governance](../../../docs/platform-governance.md#1-mandatory-tags)
- [Required Tags Policy](../../../security/policy-examples/required-tags.md)
