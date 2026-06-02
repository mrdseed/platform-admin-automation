# Azure Policy: Allowed Regions

Restricts resource deployment to approved Azure regions.

## Approved Regions

| Region Code | Azure Region | Use Case |
|-------------|--------------|----------|
| `eastus2` | East US 2 | Primary |
| `westus2` | West US 2 | DR / secondary |

All other regions are denied at management group scope unless a time-bound exception is approved.

## Policy Rule

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "not": {
        "field": "location",
        "in": ["eastus2", "westus2", "East US 2", "West US 2"]
      }
    },
    "then": { "effect": "deny" }
  }
}
```

## Module Default

Platform modules default `location = "eastus2"`. Override only with architecture approval.

## Exception Process

1. Document business justification (data residency, latency)
2. Cloud Architect approval
3. Policy exemption with `expirationDate`
4. Record in `security/access-management/users-groups.yml` exceptions section

## Related

- [Platform Governance](../../docs/platform-governance.md#5-platform-guardrails-azure-policy)
