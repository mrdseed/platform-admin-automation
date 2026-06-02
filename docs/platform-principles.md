# Platform Engineering Principles

Standards and conventions for teams contributing to and consuming shared Azure platform infrastructure.

## 1. Infrastructure as Code

- **All** production resources are managed via OpenTofu/Terraform in this repository or approved workload repos consuming these modules
- Portal changes to production are forbidden except break-glass incidents (document within 24 hours)
- Module interfaces are versioned with Git tags: `v{major}.{minor}.{patch}`
- Breaking changes require ADR (Architecture Decision Record) in `docs/adr/`

## 2. Naming Conventions

Pattern: `{resource-type}-{workload}-{environment}-{region}-{instance}`

| Resource | Abbreviation | Example |
|----------|--------------|---------|
| Resource Group | `rg` | `rg-platform-sftp-prod-eus2-001` |
| Virtual Network | `vnet` | `vnet-spoke-prod-eus2-001` |
| Subnet | `snet` | `snet-app-prod-eus2-001` |
| Key Vault | `kv` | `kv-platform-prod-eus2-001` |
| Storage Account | `st` | `stplatformsftpprod001` (no hyphens, globally unique) |
| Linux VM | `vm` | `vm-app-prod-eus2-003` |
| Managed Identity | `id` | `id-platform-sftp-prod-001` |
| Private Endpoint | `pe` | `pe-kv-platform-prod-eus2-001` |

Region codes: `eus2` (East US 2), `wus2` (West US 2). Environment: `dev`, `qa`, `prod`, `hub`, `shared`.

## 3. Tagging Policy

Mandatory tags (enforced by Azure Policy `platform-mandatory-tags`):

| Tag Key | Source |
|---------|--------|
| `environment` | Module variable |
| `application` | Module variable |
| `owner` | Module variable |
| `cost-center` | Module variable |
| `data-classification` | Module variable |
| `managed-by` | `terraform` (module default) |
| `business-unit` | Module variable |

```hcl
# Applied automatically by resource-group module
tags = module.resource_group.tags
```

Full standard: [Platform Governance](platform-governance.md#1-mandatory-tags)

Optional recommended tags: `patch-group`, `backup-tier`, `expiration-date` (non-prod).

## 4. Security Standards

See [Security & Governance](security-governance.md) for the full standard.

### No Public IP on Workloads

- Workload VMs must not receive public IP addresses
- The `linux-vm` module does not create or attach public IPs
- Remote access via Azure Bastion, VPN, ExpressRoute, or private jump hosts
- Exceptions require architecture approval — see [security/policy-examples/deny-public-ip.md](../security/policy-examples/deny-public-ip.md)

### Least-Privilege RBAC

- **Do not** assign Owner or Contributor to deployment service principals
- Use custom roles in [security/custom-rbac/](../security/custom-rbac/)
- Document required permissions per pipeline in role README
- User and group assignments managed via [security/access-management/users-groups.yml](../security/access-management/users-groups.yml)

### Secrets Management

- Store secrets in Key Vault; reference via managed identity at runtime
- Never commit `.tfvars` containing secrets; use `-var` from pipeline secrets or Azure Key Vault data sources
- Enable purge protection and soft delete on all production vaults (90-day retention)

### Network

- No public IPs on VMs in production without Security exception
- Private endpoints required for: Key Vault, Storage, SQL, Cosmos DB
- NSG rules documented with ticket reference in description field

### RBAC

- Prefer managed identities over service principals
- Use custom roles when built-in roles are overly permissive — never Contributor for automation
- Role assignments at lowest applicable scope (resource > RG > subscription)
- Quarterly access review via Entra ID Access Reviews
- Manual portal RBAC changes corrected by [access-sync pipeline](../.github/workflows/access-sync.yml)

### Image Hardening

- Linux images hardened with [ansible/](../ansible/) playbooks before gallery capture
- Run `validate-image.yml` before promoting images between environments
- No manual configuration on golden images

## 5. CI/CD Standards

### GitHub Actions (this repository)

- PR validation: fmt, validate, lint, security scan
- `main` branch protected; require status checks
- OIDC to Azure — no client secrets in GitHub secrets for Azure auth
- Environment protection rules: `prod` requires manual approval + branch restriction

### GitLab CI/CD (equivalent pattern)

```yaml
# Reference pattern for GitLab consumers
stages:
  - validate
  - plan
  - apply

.terraform_base:
  image:
    name: ghcr.io/opentofu/opentofu:1.6
    entrypoint: [""]
  before_script:
    - tofu init -backend=false

validate:
  extends: .terraform_base
  stage: validate
  script:
    - tofu fmt -check -recursive
    - tofu validate

plan:qa:
  stage: plan
  environment: qa
  id_tokens:
    AZURE_OIDC_TOKEN:
      aud: api://AzureADTokenExchange
  script:
    - tofu init
    - tofu plan -var-file=qa.tfvars -out=plan.tfplan
  artifacts:
    paths:
      - plan.tfplan
```

Use `CI_JOB_JWT` or GitLab OIDC integration with Entra federated credentials scoped to project path.

## 6. Module Design Guidelines

- One logical Azure resource (or tightly coupled set) per module
- Expose `variables.tf` with validation blocks and sensible defaults for nonprod
- Output only what consumers need; mark sensitive outputs appropriately
- Include `README.md` per module with usage example and required RBAC
- Support `azurerm` provider `~> 3.90`

## 7. Environment Promotion

| Environment | Auto-Deploy | Approvals | State Key |
|-------------|-------------|-----------|-----------|
| dev | Yes, on merge to `main` | 0 | `dev/{component}/terraform.tfstate` |
| qa | No | 1 platform engineer | `qa/{component}/terraform.tfstate` |
| prod | No | 2 + change ticket | `prod/{component}/terraform.tfstate` |

## 8. Observability

- Deploy diagnostic settings to central Log Analytics workspace `law-platform-eus2-001`
- Metric alerts for: firewall health, Key Vault availability, storage availability, VM heartbeat
- Retention: 90 days hot in Log Analytics; archive to storage for 1 year (compliance)

## 9. Documentation Requirements

Every new capability requires:

1. Architecture section update in `docs/architecture.md`
2. Runbook entry if operational impact exists
3. Example under `examples/` if reusable pattern
4. Module README with input/output tables

## 10. Technical Debt & Exceptions

Exceptions to these principles require:

- Written approval from Cloud Architect
- Time-bound expiration date
- Tracking ticket in backlog with remediation plan

Review exceptions quarterly in platform team grooming.
