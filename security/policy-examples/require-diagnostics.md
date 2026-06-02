# Azure Policy: Require Diagnostic Settings

Ensures resources ship logs and metrics to the central Log Analytics workspace.

## Scope

DeployIfNotExists or Audit on:

- Key Vault
- Storage accounts
- Virtual networks (flow logs where enabled)
- Linux VMs (via Azure Monitor Agent — validated in CI)

Central workspace: `law-platform-eus2-001` in management subscription.

## Policy Rule (DeployIfNotExists — concept)

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "field": "type",
      "in": [
        "Microsoft.KeyVault/vaults",
        "Microsoft.Storage/storageAccounts"
      ]
    },
    "then": {
      "effect": "deployIfNotExists",
      "details": {
        "type": "Microsoft.Insights/diagnosticSettings",
        "existenceCondition": {
          "field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
          "equals": true
        },
        "roleDefinitionIds": [
          "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d07873"
        ],
        "deployment": {
          "properties": {
            "mode": "incremental",
            "template": { "...": "deploy diagnostic setting to central LAW" }
          }
        }
      }
    }
  }
}
```

## Module Alignment

Platform modules accept `log_analytics_workspace_id` and create diagnostic settings when provided:

- [key-vault](../../terraform/modules/key-vault/)
- [storage-account](../../terraform/modules/storage-account/)
- [linux-vm](../../terraform/modules/linux-vm/) — Azure Monitor Agent extension

CI validation fails modules that omit diagnostics on stateful resources where the variable exists.

## Related

- [Platform Governance](../../docs/platform-governance.md#5-platform-guardrails-azure-policy)
