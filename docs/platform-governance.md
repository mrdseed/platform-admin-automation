# Platform Governance

Enterprise governance standards for Azure landing zones: tagging, naming, subscriptions, state backends, guardrails, network, identity, and operations.

## Document Control

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Owner | Platform Engineering |
| Review Cycle | Quarterly |

---

## 1. Mandatory Tags

All resources created via platform modules must carry the following tags. Azure Policy initiative `platform-mandatory-tags` denies create/update when any tag is missing (production management group).

| Tag Key | Description | Example | Source |
|---------|-------------|---------|--------|
| `environment` | Lifecycle stage | `dev`, `qa`, `prod`, `hub`, `shared` | Variable |
| `application` | Workload or service identifier | `platform-sftp` | Variable |
| `owner` | Contact email for the resource | `platform-team@example.com` | Variable |
| `cost-center` | Chargeback code | `CC-1042` | Variable |
| `data-classification` | Sensitivity level | `internal`, `confidential` | Variable |
| `managed-by` | Provisioning tool | `terraform` | Module default |
| `business-unit` | Business unit or division | `engineering` | Variable |

### Module Enforcement

The [resource-group](../terraform/modules/resource-group/) module builds mandatory tags and exposes them via `module.resource_group.tags` for all downstream modules.

```hcl
module "resource_group" {
  source = "../../modules/resource-group"

  name             = "rg-platform-app-prod-eus2-001"
  environment      = "prod"
  application_name = "platform-app"
  owner_email      = "platform-team@example.com"
  cost_center      = "CC-1042"
  business_unit    = "engineering"
  data_classification = "confidential"
}
```

Policy reference: [security/policy-examples/required-tags.md](../security/policy-examples/required-tags.md)

Optional recommended tags: `patch-group`, `backup-tier`, `expiration-date` (non-prod).

---

## 2. Naming Conventions

### Pattern

```
{resource-type}-{workload}-{environment}-{region}-{instance}
```

- **resource-type** — approved abbreviation (see table)
- **workload** — short application code (`platform`, `sftp`, `app`)
- **environment** — `dev`, `qa`, `prod`, `hub`, `shared`
- **region** — `eus2`, `wus2`
- **instance** — three-digit sequence (`001`)

Storage accounts omit hyphens: `{st}{workload}{env}{instance}` → `stplatformprod001`

### Approved Abbreviations

| Resource | Prefix | Example |
|----------|--------|---------|
| Resource group | `rg` | `rg-platform-app-prod-eus2-001` |
| Virtual network | `vnet` | `vnet-spoke-prod-eus2-001` |
| Subnet | `snet` | `snet-app-prod-eus2-001` |
| NSG | `nsg` | `nsg-app-prod-eus2-001` |
| Route table | `udr` | `udr-spoke-prod-eus2-default` |
| Key Vault | `kv` | `kv-platform-prod-eus2-001` |
| Storage account | `st` | `stplatformprod001` |
| Linux VM | `vm` | `vm-app-prod-eus2-001` |
| Managed identity | `id` | `id-platform-app-prod-001` |
| Private endpoint | `pe` | `pe-kv-platform-prod-eus2-001` |
| Log Analytics | `law` | `law-platform-prod-eus2-001` |
| Azure Firewall | `afw` | `afw-hub-eus2-001` |
| Bastion | `bas` | `bas-hub-eus2-001` |

### Rules

- No hand-named or random resources in production (`vm-test-123`, `rg-temp`)
- Environment must appear in the name for non-shared resources
- Workload abbreviation must match `application` tag value
- Sequence increments per resource type within scope — never reuse deleted names in prod without change ticket

Full reference: [platform-principles.md](platform-principles.md#2-naming-conventions)

---

## 3. Multi-Subscription Governance

### Subscription Layout

| Management Group | Subscription ID (example) | Purpose |
|------------------|---------------------------|---------|
| `mg-connectivity` | `sub-connectivity` | Hub VNet, firewall, ExpressRoute, Bastion, private DNS |
| `mg-management` | `sub-management` | Log Analytics, automation accounts, state storage (optional) |
| `mg-shared` | `sub-shared` | Shared Key Vault (optional), gallery images, patch storage |
| `mg-nonprod` | `sub-workload-dev` | Development workloads |
| `mg-nonprod` | `sub-workload-qa` | QA / pre-production |
| `mg-prod` | `sub-workload-prod` | Production workloads |

### Separation Principles

- **Management plane** (connectivity, shared services) is isolated from **workload** subscriptions
- Workload teams deploy only into their environment subscription via scoped pipeline principals
- Central logging: diagnostic settings ship to `law-platform-eus2-001` in management or connectivity subscription
- **Key Vault model:**
  - *Central platform vault* — shared secrets (pipeline, monitoring) in `sub-shared`
  - *Per-workload vault* — application secrets in workload subscription (recommended for prod)
- **RBAC boundaries:** no standing Owner on workload subscriptions; Reader for operators; custom deploy roles for pipelines

See [architecture.md](architecture.md#subscription--management-group-layout) and [security/access-management/users-groups.yml](../security/access-management/users-groups.yml).

---

## 4. Remote State & Backend Access

### Requirements

| Control | Implementation |
|---------|----------------|
| Secure backend | Azure Storage with GRS, versioning, soft delete |
| Network lockdown | Public network access disabled; private endpoint preferred |
| Access | Pipeline managed identity only — `Storage Blob Data Contributor` on state container |
| Encryption | Microsoft-managed keys minimum; CMK for prod optional |
| Break-glass | Documented emergency access; not used for routine deploys |

Bootstrap example: [terraform/bootstrap/state-backend/](../terraform/bootstrap/state-backend/)

State key convention: `{environment}/{component}/terraform.tfstate`

### Break-Glass

- Break-glass account holds `Storage Blob Data Owner` on state account — PIM eligible, not permanent
- Usage requires incident ticket and post-incident review within 24 hours
- Normal deployments use OIDC federated credentials only

Details: [backend-state-governance.md](backend-state-governance.md)

---

## 5. Platform Guardrails (Azure Policy)

| Policy | Effect | Scope |
|--------|--------|-------|
| Deny public IP on VMs/NICs | Deny | Workload MG |
| Require mandatory tags | Deny | All |
| Allowed regions | Deny | All (`eastus2`, `westus2`) |
| Require diagnostic settings | DeployIfNotExists / Audit | All |
| Require private endpoint (PaaS) | Audit → Deny (prod) | Prod MG |
| Block resource creation without `managed-by` | Deny | Prod MG |

Policy examples: [security/policy-examples/](../security/policy-examples/)

### Manual Production Changes

- Portal and CLI changes to production are **not permitted** for routine work
- Drift detected by pipeline or policy compliance scan
- Remediation: revert via IaC or open emergency change — see [runbook.md](runbook.md)

---

## 6. Network Governance

| Standard | Requirement |
|----------|-------------|
| Topology | Hub-and-spoke — workloads in spokes, shared services in hub |
| Egress | Forced tunneling via Azure Firewall (`0.0.0.0/0` → firewall private IP) |
| Route tables | Spoke subnets associated with UDR — no direct Internet egress |
| NSG | Default deny inbound from Internet; explicit allow rules documented |
| Private DNS | `privatelink.*` zones in hub; linked to all spokes |
| Remote access | VPN, ExpressRoute, Bastion, or jump host — **no workload public IPs** |

Modules: [virtual-network](../terraform/modules/virtual-network/), [subnet](../terraform/modules/subnet/), [network-security-group](../terraform/modules/network-security-group/), [route-table](../terraform/modules/route-table/), [private-endpoint](../terraform/modules/private-endpoint/)

---

## 7. Identity Governance

| Standard | Implementation |
|----------|----------------|
| Groups in code | [security/access-management/users-groups.yml](../security/access-management/users-groups.yml) |
| User assignments | YAML source of truth; sync via [access-sync.yml](../.github/workflows/access-sync.yml) |
| Service principals | Custom RBAC only — [security/custom-rbac/](../security/custom-rbac/) |
| Workload auth | User-assigned managed identities preferred |
| No standing Owner | Owner blocked in access catalog; PIM for break-glass only |
| Pipeline identity | Separate SP/MI per environment subscription |

Denied roles in access catalog: `Owner`, `Contributor`, `User Access Administrator`

---

## 8. Operational Governance

| Requirement | Implementation |
|-------------|----------------|
| Runbooks | [runbook.md](runbook.md) — required before production promotion |
| Change history | All changes via pull request to `main` |
| Validation | [validation.yml](../.github/workflows/validation.yml) — fmt, validate, lint, Checkov |
| Promotion | dev (auto) → qa (1 approval) → prod (2 approvals + change ticket) |
| Prod approval | GitHub environment protection on `prod` |

### Promotion Model

```
feature branch → PR → validation passes → merge
  → dev: automatic apply
  → qa: manual approval + plan review
  → prod: change ticket + 2 approvers + maintenance window
```

---

## Related Documents

- [Security & Governance](security-governance.md)
- [Platform Principles](platform-principles.md)
- [Architecture](architecture.md)
- [Operational Runbook](runbook.md)
- [Backend State Governance](backend-state-governance.md)
