# Azure Policy: Required Tags

Ensures all resources inherit mandatory platform tags for cost allocation, ownership, and compliance.

## Mandatory Tags

| Tag | Validation | Example |
|-----|------------|---------|
| `Environment` | Allowed: `dev`, `qa`, `prod`, `hub`, `shared` | `prod` |
| `CostCenter` | Pattern: `CC-[0-9]{4}` | `CC-1042` |
| `Owner` | Valid email format | `platform-team@example.com` |
| `Application` | Non-empty string | `platform-sftp` |
| `ManagedBy` | Must equal `terraform` or `pipeline` | `terraform` |
| `DataClassification` | Allowed: `public`, `internal`, `confidential`, `restricted` | `internal` |

## Policy Rule (Concept)

Use an initiative combining:

1. **Append** — add `ManagedBy: terraform` when missing (non-prod)
2. **Deny** — block create/update when mandatory tags absent (prod)
3. **Audit** — report non-compliant existing resources for remediation

Example deny fragment:

```json
{
  "if": {
    "anyOf": [
      { "field": "tags['Environment']", "exists": false },
      { "field": "tags['CostCenter']", "exists": false },
      { "field": "tags['Owner']", "exists": false },
      { "field": "tags['Application']", "exists": false },
      { "field": "tags['ManagedBy']", "exists": false },
      { "field": "tags['DataClassification']", "exists": false }
    ]
  },
  "then": { "effect": "deny" }
}
```

## Terraform Module Enforcement

All modules under `terraform/modules/` merge mandatory tags via locals:

```hcl
locals {
  mandatory_tags = {
    Environment        = var.environment
    CostCenter         = var.cost_center
    Owner              = var.owner_email
    Application        = var.application_name
    ManagedBy          = "terraform"
    DataClassification = var.data_classification
  }
}
```

## Remediation

Non-compliant resources identified by audit policy:

1. Platform team assigns tags via pipeline import or targeted apply
2. Non-prod resources without `ExpirationDate` flagged for deletion review
3. Repeat offenders tracked in monthly governance report

## Related

- [Platform Principles — Tagging](../../docs/platform-principles.md#3-tagging-policy)
- [Deny Public IP Policy](deny-public-ip.md)
