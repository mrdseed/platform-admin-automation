# Terraform Modules

Reusable OpenTofu/Terraform modules for secure Azure platform landing zones.

## Quick Reference

| Module | Creates | Security highlight |
|--------|---------|-------------------|
| [resource-group](resource-group/) | RG + tags + optional lock | Mandatory tagging |
| [virtual-network](virtual-network/) | VNet + hub peering | No public IP |
| [subnet](subnet/) | Subnet | Private segmentation |
| [network-security-group](network-security-group/) | NSG + rules | Default deny Internet |
| [route-table](route-table/) | UDR + associations | Firewall egress |
| [storage-account](storage-account/) | Storage + diagnostics | Public access off |
| [key-vault](key-vault/) | KV RBAC + diagnostics | No access policies |
| [linux-vm](linux-vm/) | Private VM + AMA | **No public IP** |
| [managed-identity](managed-identity/) | User-assigned MI | Passwordless access |
| [role-assignment](role-assignment/) | RBAC | Blocks Contributor |
| [private-endpoint](private-endpoint/) | Private Link | Private-first PaaS |
| [log-analytics-workspace](log-analytics-workspace/) | LAW | Central diagnostics |

## Composition Pattern

Modules are designed to chain via outputs:

```
resource-group.tags
    └── virtual-network → subnet → nsg (subnet_ids)
                            └── linux-vm (subnet_id)
    └── log-analytics.id / .workspace_id
    └── storage-account → private-endpoint
    └── key-vault → private-endpoint
    └── managed-identity → role-assignment
```

See [examples/secure-platform-baseline/](../../examples/secure-platform-baseline/) for a complete wiring example.

## Standards

- Pass `module.resource_group.tags` to all taggable resources
- Never hardcode subscription ID, tenant ID, or secrets
- Use custom RBAC roles for pipeline principals
- Deploy production via CI/CD pipeline only
