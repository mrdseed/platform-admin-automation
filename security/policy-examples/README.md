# Policy Examples Index

Azure Policy reference patterns aligned with [Platform Governance](../../docs/platform-governance.md).

| Policy | File | Effect |
|--------|------|--------|
| Required mandatory tags | [required-tags.md](required-tags.md) | Deny |
| Deny public IP on workloads | [deny-public-ip.md](deny-public-ip.md) | Deny |
| Allowed regions | [allowed-regions.md](allowed-regions.md) | Deny |
| Require diagnostic settings | [require-diagnostics.md](require-diagnostics.md) | DeployIfNotExists |
| Require private endpoints (prod) | [require-private-endpoint.md](require-private-endpoint.md) | Audit / Deny |

Initiative name: `platform-guardrails` — assigned at root management group with prod-specific overrides on `mg-prod`.

## Deployment

Policies are defined as JSON concepts in this folder. Deploy via:

- Terraform `azurerm_policy_definition` / `azurerm_policy_set_definition`
- Azure Portal policy library import
- GitOps pipeline from dedicated policy repository

## Compliance Reporting

Monthly export from Azure Policy compliance → Log Analytics → governance dashboard.

Non-compliance in production triggers ticket in platform backlog within 5 business days.
