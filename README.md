# Platform Admin Automation

Azure platform engineering repository for infrastructure-as-code, hub-and-spoke networking, identity-based security, VM standardization, and operational automation.

## Scope

| Area | Description |
|------|-------------|
| **Networking** | Hub-and-spoke topology with Azure Firewall, UDRs, and private DNS |
| **Identity & Security** | Managed identities, Key Vault RBAC, least-privilege role assignments |
| **Compute** | Standardized Linux VM baselines with cloud-init and Azure Policy alignment |
| **Transfer Platform** | SFTP landing zone with private endpoints and audit logging |
| **Automation** | Terraform/OpenTofu modules, GitHub Actions validation, GitLab CI/CD patterns |
| **Security & Governance** | Custom RBAC, access catalog, policy examples, Ansible hardening |
| **Operations** | Runbooks, tagging standards, and environment promotion workflows |

## Platform Security Principles

- **Private by default** — private endpoints and private networking for workloads
- **No public IPs on workloads** — access via Bastion, VPN, or jump hosts only
- **Least privilege by default** — custom RBAC for pipelines, not Owner/Contributor
- **Pipeline-only infrastructure changes** — no manual production portal changes
- **Source-controlled access** — users and groups defined in Git, enforced by pipeline
- **Secrets in Key Vault** — never in source control
- **Hardened images** — built, validated, and promoted via Ansible automation

## Repository Layout

```
platform-admin-automation/
├── ansible/                 # Linux hardening playbooks and roles
├── docs/                    # Architecture, runbooks, principles, security
├── examples/                # Reference implementations by capability
├── security/
│   ├── custom-rbac/         # Scoped deployment role definitions
│   ├── access-management/   # Users, groups, RBAC source of truth
│   └── policy-examples/     # Azure Policy reference patterns
├── terraform/
│   ├── modules/             # Reusable IaC modules
│   └── environments/        # dev / qa / prod root modules
├── .github/workflows/       # CI validation and access-sync pipelines
└── diagrams/                # Mermaid architecture diagrams
```

## Quick Start

### Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.6 or Terraform >= 1.5
- Azure CLI authenticated to target subscription
- Appropriate RBAC: scoped custom deploy roles (see [security/custom-rbac/](security/custom-rbac/))

### Validate Locally

```bash
tofu fmt -recursive terraform/
tofu init -backend=false terraform/modules/resource-group
tofu validate terraform/modules/resource-group
```

CI runs the same checks defined in [.github/workflows/validation.yml](.github/workflows/validation.yml).

### Deploy an Environment

```bash
cd terraform/environments/dev
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

State is stored remotely in Azure Storage with OIDC-based pipeline authentication. See each environment's `providers.tf` for backend configuration.

## Architecture Overview

Production workloads run in **spoke** virtual networks peered to a central **hub** that hosts shared services (firewall, DNS, bastion, monitoring). Secrets flow through **Azure Key Vault** with RBAC—not access policies—and compute uses **user-assigned managed identities** for secret retrieval.

```
                    ┌─────────────────────────────────────┐
                    │           Azure Hub VNet            │
                    │  Firewall · Bastion · DNS · Logs  │
                    └──────────────┬──────────────────────┘
                                   │ VNet Peering
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
        ┌───────────┐        ┌───────────┐        ┌───────────┐
        │ Dev Spoke │        │ QA Spoke  │        │Prod Spoke │
        └───────────┘        └───────────┘        └───────────┘
```

Detailed design: [docs/architecture.md](docs/architecture.md)

## Modules

| Module | Purpose |
|--------|---------|
| [resource-group](terraform/modules/resource-group/) | Tagged resource groups with lock and RBAC hooks |
| [virtual-network](terraform/modules/virtual-network/) | Hub/spoke VNet and peering |
| [subnet](terraform/modules/subnet/) | Subnets within a VNet |
| [network-security-group](terraform/modules/network-security-group/) | NSG rules and subnet associations |
| [route-table](terraform/modules/route-table/) | UDRs for firewall egress |
| [storage-account](terraform/modules/storage-account/) | Private-first storage with diagnostics |
| [key-vault](terraform/modules/key-vault/) | RBAC-enabled vault with diagnostics |
| [linux-vm](terraform/modules/linux-vm/) | Linux VM — private IP only, no public IP |
| [managed-identity](terraform/modules/managed-identity/) | User-assigned managed identity |
| [role-assignment](terraform/modules/role-assignment/) | Scoped RBAC — blocks Contributor/Owner |
| [private-endpoint](terraform/modules/private-endpoint/) | Private Link endpoints |
| [log-analytics-workspace](terraform/modules/log-analytics-workspace/) | Central Log Analytics |

Full index: [terraform/modules/README.md](terraform/modules/README.md)

## Examples

| Example | Path |
|---------|------|
| Hub-and-spoke networking | [examples/hub-spoke-networking/](examples/hub-spoke-networking/) |
| Key Vault RBAC patterns | [examples/key-vault-rbac/](examples/key-vault-rbac/) |
| Linux VM standardization | [examples/linux-vm-standardization/](examples/linux-vm-standardization/) |
| SFTP transfer platform | [examples/sftp-platform/](examples/sftp-platform/) |
| No public IP standard | [examples/no-public-ip/](examples/no-public-ip/) |

## CI/CD

Pull requests trigger [.github/workflows/validation.yml](.github/workflows/validation.yml) and access changes trigger [.github/workflows/access-sync.yml](.github/workflows/access-sync.yml):

- `tofu fmt -check`
- `tofu init -backend=false` + `tofu validate` per module
- TFLint and Checkov static analysis
- Reject `azurerm_public_ip` in workload modules
- Validate `security/access-management/users-groups.yml` (denied roles, schema)
- OIDC federation to Azure for plan-only jobs on `main` (optional)

GitLab CI equivalents are documented in [docs/platform-principles.md](docs/platform-principles.md#cicd-standards).

## Tagging Standard

All resources inherit mandatory tags enforced via module defaults and Azure Policy:

| Tag | Example | Required |
|-----|---------|----------|
| `Environment` | `dev`, `qa`, `prod` | Yes |
| `CostCenter` | `CC-1042` | Yes |
| `Owner` | `platform-team@example.com` | Yes |
| `Application` | `platform-sftp` | Yes |
| `ManagedBy` | `terraform` | Yes |
| `DataClassification` | `internal`, `confidential` | Yes |

## Security Posture

- **No public IPs on workload VMs** — Bastion/VPN/jump host access only
- **No secrets in Git** — Key Vault, pipeline variables, and OIDC only
- **Custom RBAC for pipelines** — not Owner or Contributor ([security/custom-rbac/](security/custom-rbac/))
- **Pipeline-managed access** — [users-groups.yml](security/access-management/users-groups.yml)
- **RBAC over access policies** for Key Vault
- **Private endpoints** for PaaS where supported
- **Ansible-hardened images** — [ansible/](ansible/)
- **Managed identities** preferred over service principals with client secrets
- **Diagnostic settings** shipped to Log Analytics on all module outputs

## Operations

- [Security & Governance](docs/security-governance.md) — platform security standards
- [Operational Runbook](docs/runbook.md) — incident response, deployment, rollback
- [Platform Principles](docs/platform-principles.md) — engineering standards
- [Project Roadmap](docs/project-roadmap.md) — planned capabilities
- [Ansible Hardening](ansible/README.md) — image build, test, promote

## Contributing

1. Branch from `main` using `feature/<ticket>-<short-description>`
2. Run local validation before push
3. Require two reviewer approvals for `prod` environment changes
4. Document breaking module changes in PR description
