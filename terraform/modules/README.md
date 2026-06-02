# Terraform Modules

Reusable OpenTofu/Terraform modules for Azure platform components. Each module includes `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and `README.md`.

## Module Index

| Module | Purpose |
|--------|---------|
| [resource-group](resource-group/) | Tagged resource groups with optional delete lock |
| [virtual-network](virtual-network/) | VNet and hub peering |
| [subnet](subnet/) | Subnets within a VNet |
| [network-security-group](network-security-group/) | NSG, rules, subnet associations |
| [route-table](route-table/) | UDRs and subnet associations |
| [storage-account](storage-account/) | Private-first storage with diagnostics |
| [key-vault](key-vault/) | RBAC Key Vault with diagnostics |
| [linux-vm](linux-vm/) | Linux VM — **private IP only**, no public IP |
| [managed-identity](managed-identity/) | User-assigned managed identity |
| [role-assignment](role-assignment/) | RBAC assignments — blocks Contributor/Owner |
| [private-endpoint](private-endpoint/) | Generic private endpoint |
| [log-analytics-workspace](log-analytics-workspace/) | Log Analytics workspace |

## Design Standards

- **No public IPs** on workload VMs by default
- **Required tags** via `tags` variable (set from environment `local.platform_tags`)
- **Naming conventions** documented per module (`{type}-{workload}-{env}-{region}-{seq}`)
- **Environment-aware** — `environment` variable validated on applicable modules
- **Least privilege** — use custom RBAC roles from [security/custom-rbac/](../../security/custom-rbac/)
- **Private endpoints** composed via `private-endpoint` module
- **Diagnostics** on Key Vault, storage, and VM (via Log Analytics ID)
- **No hardcoded** subscription IDs, tenant IDs, passwords, or secrets

## Environment Composition

Environments under `terraform/environments/{dev,qa,prod}/` demonstrate full module composition:

- Resource group → Log Analytics → VNet → Subnets → NSG → Route table
- Storage → Managed identity → Key Vault → Private endpoints → RBAC → Linux VM

## Validation

```bash
tofu fmt -recursive terraform/
for m in resource-group virtual-network subnet network-security-group route-table storage-account key-vault linux-vm managed-identity role-assignment private-endpoint log-analytics-workspace; do
  (cd "terraform/modules/$m" && tofu init -backend=false && tofu validate)
done
```

CI validates all modules via [.github/workflows/validation.yml](../../.github/workflows/validation.yml).
