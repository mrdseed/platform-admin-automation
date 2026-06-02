# Azure Policy: Required Tags

Enforces mandatory platform tags on all indexed resources.

## Mandatory Tags

| Tag Key | Validation | Example |
|---------|------------|---------|
| `environment` | `dev`, `qa`, `prod`, `hub`, `shared` | `prod` |
| `application` | Non-empty string | `platform-sftp` |
| `owner` | Valid email format | `platform-team@acmecorp.com` |
| `cost-center` | Pattern `CC-[0-9]{4}` | `CC-1042` |
| `data-classification` | `public`, `internal`, `confidential`, `restricted` | `confidential` |
| `managed-by` | `terraform` or `pipeline` | `terraform` |
| `business-unit` | Non-empty string | `engineering` |

## Policy Rule (Deny)

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "anyOf": [
        { "field": "tags['environment']", "exists": "false" },
        { "field": "tags['application']", "exists": "false" },
        { "field": "tags['owner']", "exists": "false" },
        { "field": "tags['cost-center']", "exists": "false" },
        { "field": "tags['data-classification']", "exists": "false" },
        { "field": "tags['managed-by']", "exists": "false" },
        { "field": "tags['business-unit']", "exists": "false" }
      ]
    },
    "then": { "effect": "deny" }
  }
}
```

## Terraform Module Alignment

The [resource-group](../../terraform/modules/resource-group/) module applies all mandatory tags:

```hcl
locals {
  mandatory_tags = {
    environment         = var.environment
    application         = var.application_name
    owner               = var.owner_email
    cost-center         = var.cost_center
    data-classification = var.data_classification
    managed-by          = "terraform"
    business-unit       = var.business_unit
  }
}
```

Downstream modules receive tags via `module.resource_group.tags`.

## Remediation

1. Audit non-compliant resources via Azure Policy compliance dashboard
2. Remediate via Terraform import + apply or targeted tag update pipeline
3. Non-prod resources missing `expiration-date` flagged in monthly governance report

## Related

- [Platform Governance](../../docs/platform-governance.md#1-mandatory-tags)
- [Deny Public IP Policy](deny-public-ip.md)
