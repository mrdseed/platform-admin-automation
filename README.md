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
| **Operations** | Runbooks, tagging standards, and environment promotion workflows |

## Repository Layout

```
platform-admin-automation/
├── docs/                    # Architecture, runbooks, principles, roadmap
├── examples/                # Reference implementations by capability
├── terraform/
│   ├── modules/             # Reusable IaC modules
│   └── environments/        # dev / qa / prod root modules
├── .github/workflows/       # CI validation pipeline
└── diagrams/                # Mermaid architecture diagrams
```

## Quick Start

### Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.6 or Terraform >= 1.5
- Azure CLI authenticated to target subscription
- Appropriate RBAC: `Contributor` on workload RGs, `User Access Administrator` for role assignments (or pipeline SPN)

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
| [virtual-network](terraform/modules/virtual-network/) | Hub/spoke VNet, subnets, NSGs, UDRs |
| [key-vault](terraform/modules/key-vault/) | RBAC-enabled vault, private endpoint, diagnostics |
| [linux-vm](terraform/modules/linux-vm/) | Standardized RHEL/Ubuntu VM with MI and extensions |

## Examples

| Example | Path |
|---------|------|
| Hub-and-spoke networking | [examples/hub-spoke-networking/](examples/hub-spoke-networking/) |
| Key Vault RBAC patterns | [examples/key-vault-rbac/](examples/key-vault-rbac/) |
| Linux VM standardization | [examples/linux-vm-standardization/](examples/linux-vm-standardization/) |
| SFTP transfer platform | [examples/sftp-platform/](examples/sftp-platform/) |

## CI/CD

Pull requests trigger [.github/workflows/validation.yml](.github/workflows/validation.yml):

- `tofu fmt -check`
- `tofu init -backend=false` + `tofu validate` per module
- TFLint and Checkov static analysis
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

- **No secrets in Git** — Key Vault, pipeline variables, and OIDC only
- **RBAC over access policies** for Key Vault
- **Private endpoints** for PaaS where supported
- **Deny public access** on storage accounts backing SFTP
- **Managed identities** preferred over service principals with client secrets
- **Diagnostic settings** shipped to Log Analytics on all module outputs

## Operations

- [Operational Runbook](docs/runbook.md) — incident response, deployment, rollback
- [Platform Principles](docs/platform-principles.md) — engineering standards
- [Project Roadmap](docs/project-roadmap.md) — planned capabilities

## Contributing

1. Branch from `main` using `feature/<ticket>-<short-description>`
2. Run local validation before push
3. Require two reviewer approvals for `prod` environment changes
4. Document breaking module changes in PR description
