# Azure Policy: Require Private Endpoints (Production)

Audits and progressively denies PaaS resources that accept public network traffic without a private endpoint.

## Target Services (Production)

| Service | Subresource | Policy Phase |
|---------|-------------|--------------|
| Key Vault | `vault` | Deny (prod) |
| Storage Account | `blob` | Deny (prod) |
| SQL Database | `sqlServer` | Audit → Deny |

## Audit Rule (Concept)

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        { "field": "type", "equals": "Microsoft.KeyVault/vaults" },
        { "field": "Microsoft.KeyVault/vaults/publicNetworkAccess", "equals": "Enabled" },
        { "field": "tags['environment']", "equals": "prod" }
      ]
    },
    "then": { "effect": "deny" }
  }
}
```

## Module Defaults

| Module | Default |
|--------|---------|
| `key-vault` | `public_network_access_enabled = false` |
| `storage-account` | `public_network_access_enabled = false` |
| `private-endpoint` | Composed for private connectivity |

## Validation

Production stacks must include `private-endpoint` modules for Key Vault and Storage. See [secure-platform-baseline](../../examples/secure-platform-baseline/).

## Related

- [Platform Governance](../../docs/platform-governance.md#6-network-governance)
- [Deny Public IP](deny-public-ip.md)
