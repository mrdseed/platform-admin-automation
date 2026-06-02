# Azure Policy: Deny Public IP on Workload VMs

Enforces the platform standard that workload VMs must not receive public IP addresses.

## Policy Intent

| Setting | Value |
|---------|-------|
| Effect | Deny |
| Scope | Production management group (`mg-prod`) |
| Exception process | Security architecture review + time-bound exemption |

## Policy Rule (Concept)

Deploy via Azure Policy definition or Terraform `azurerm_policy_definition`:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Network/networkInterfaces"
        },
        {
          "count": {
            "field": "Microsoft.Network/networkInterfaces/ipConfigurations[*].publicIPAddress.id",
            "where": {
              "field": "Microsoft.Network/networkInterfaces/ipConfigurations[*].publicIPAddress.id",
              "exists": true
            }
          },
          "greater": 0
        },
        {
          "field": "tags['Environment']",
          "equals": "prod"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
}
```

## Approved Remote Access Paths

When public IP is denied, use:

| Method | Use Case |
|--------|----------|
| Azure Bastion | Interactive admin SSH/RDP |
| VPN / ExpressRoute | Operator access from corporate network |
| Private jump host | Automation and break-glass on `snet-mgmt-*` subnet |
| Serial console | Last-resort platform recovery (logged) |

## Security Exception Process

Public IP may be granted **only** when:

1. Business justification documented in change ticket
2. Cloud Architect approval
3. Azure Policy exemption with `expirationDate`
4. NSG restricts source IPs to known ranges
5. Exception recorded in `security/access-management/users-groups.yml` under `exceptions`

```yaml
exceptions:
  - resource: /subscriptions/.../resourceGroups/rg-legacy-app/providers/Microsoft.Network/publicIPAddresses/pip-legacy-temp
    reason: "Legacy vendor integration — migration planned Q4 2026"
    ticket: CHG-12345
    expires: "2026-12-31"
    approved_by: cloud-arch@acmecorp.com
```

## Terraform Alignment

The [linux-vm module](../../terraform/modules/linux-vm/) does not create `azurerm_public_ip` resources. Attempts to attach public IPs require a separate module or explicit exception.

See [examples/no-public-ip/](../../examples/no-public-ip/).

## Monitoring

Alert on policy deny events:

```kusto
AzureActivity
| where OperationNameValue == "Microsoft.Authorization/policies/denyAction/action"
| where Properties contains "publicIPAddress"
| summarize count() by Caller, ResourceGroup
```

## Related

- [Security & Governance](../../docs/security-governance.md)
- [Required Tags Policy](required-tags.md)
