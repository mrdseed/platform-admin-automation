# Platform Engineering Roadmap

Quarterly roadmap for shared Azure platform capabilities. Status as of **Q2 2026**.

## Vision

Deliver a secure, automated, and observable Azure landing zone that enables application teams to deploy workloads in hours—not weeks—while maintaining enterprise compliance and operational consistency.

---

## Current State (Completed)

| Capability | Status | Module / Doc Reference |
|------------|--------|------------------------|
| Hub-and-spoke networking | ✅ Production | `terraform/modules/virtual-network` |
| Key Vault RBAC baseline | ✅ Production | `terraform/modules/key-vault` |
| Linux VM standardization | ✅ Production | `terraform/modules/linux-vm` |
| SFTP transfer platform | ✅ Production | `examples/sftp-platform` |
| GitHub Actions validation pipeline | ✅ Active | `.github/workflows/validation.yml` |
| Access sync pipeline | ✅ Active | `.github/workflows/access-sync.yml` |
| Custom RBAC role definitions | ✅ Defined | `security/custom-rbac/` |
| Ansible image hardening | ✅ Defined | `ansible/` |
| No public IP standard | ✅ Enforced | `examples/no-public-ip/`, Azure Policy |
| Centralized Log Analytics | ✅ Production | Hub deployment |
| Managed identity patterns | ✅ Production | All modules |
| Tagging & naming standards | ✅ Enforced via Policy | `docs/platform-principles.md` |

---

## Q2 2026 — In Progress

| Item | Priority | Owner | Target | Notes |
|------|----------|-------|--------|-------|
| OpenTofu 1.7 migration | P1 | Platform Eng | Jun 2026 | Pin provider versions; test all modules |
| Azure Policy remediation tasks | P1 | Security | Jun 2026 | Auto-remediate missing diagnostics |
| Spoke VNet automation for self-service | P2 | Platform Eng | Jul 2026 | Pipeline template for app teams |
| Checkov policy-as-code gates | P2 | DevSecOps | Jun 2026 | Block PR on HIGH findings |
| DR failover runbook drill | P1 | SRE | May 2026 | SFTP RA-GRS validation |

---

## Q3 2026 — Planned

| Item | Priority | Description |
|------|----------|-------------|
| AKS landing zone submodule | P1 | Spoke-integrated private cluster with workload identity |
| Private DNS automation | P2 | Auto-registration for PE records across spokes |
| Cost allocation dashboards | P2 | Azure Cost Management + mandatory tag enforcement |
| GitLab CI component library | P2 | Reusable `include` for `.terraform_base` jobs |
| Secrets rotation automation | P1 | Key Vault rotation function for SFTP keys |

---

## Q4 2026 — Planned

| Item | Priority | Description |
|------|----------|-------------|
| West US 2 secondary region | P1 | Hub-spoke extension for geo-redundancy |
| Azure Firewall Premium IDPS | P2 | Enable IDPS signatures on prod firewall policy |
| VMSS standardization module | P2 | Autoscale app tier pattern |
| FinOps review automation | P3 | Weekly orphaned resource reports |
| Policy-driven VM decommissioning | P2 | Auto-shutdown nonprod after `ExpirationDate` |

---

## Backlog (Unscheduled)

- Azure Arc onboarding for hybrid servers
- OpenTelemetry collector standard deployment
- Terraform Cloud / Spacelift evaluation for state management
- Custom Azure RBAC role library as standalone module
- Partner SFTP self-service portal (API-backed)

---

## Deprecation Notices

| Component | Deprecation Date | Replacement |
|-----------|------------------|-------------|
| Key Vault access policies | 2025-12-01 (enforced) | RBAC authorization |
| Log Analytics MMA agent | 2026-08-01 | Azure Monitor Agent |
| Terraform `< 1.5` | 2026-06-01 | OpenTofu 1.6+ |

---

## How to Propose Work

1. Open GitHub issue with template `Platform Feature Request`
2. Include business justification, affected teams, and security impact
3. Platform team triages in weekly grooming (Wednesdays)
4. Approved items added to this roadmap with quarter assignment

Contact: `platform-team@acmecorp.com`
