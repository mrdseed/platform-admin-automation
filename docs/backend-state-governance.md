# Backend State Governance

Standards for OpenTofu/Terraform remote state storage and access control.

## State Storage Account

| Setting | Value |
|---------|-------|
| Name | `stplatformtf{env}001` (globally unique) |
| Resource group | `rg-platform-tfstate-eus2-001` |
| Subscription | `sub-management` (management plane) |
| Replication | GRS |
| Public network access | **Disabled** |
| Shared key access | Disabled for operators; pipeline uses OIDC + RBAC |
| Versioning | Enabled |
| Soft delete | 30-day retention minimum |
| Private endpoint | Preferred on `snet-mgmt-hub-eus2-001` |

## Container Layout

```
tfstate/
├── dev/platform/terraform.tfstate
├── qa/platform/terraform.tfstate
├── prod/platform/terraform.tfstate
└── bootstrap/state-backend/terraform.tfstate
```

## Access Model

| Principal | Role | Scope | Purpose |
|-----------|------|-------|---------|
| `id-platform-tf-dev` | Storage Blob Data Contributor | `dev/` prefix | Dev pipeline read/write |
| `id-platform-tf-qa` | Storage Blob Data Contributor | `qa/` prefix | QA pipeline read/write |
| `id-platform-tf-prod` | Storage Blob Data Contributor | `prod/` prefix | Prod pipeline read/write |
| Break-glass group (PIM) | Storage Blob Data Owner | Container | Emergency state recovery only |
| Platform engineers | Storage Blob Data Reader | Container | Plan-only local debugging (non-prod) |

No human principal receives write access to production state for routine operations.

## Backend Configuration

Environment backends use OIDC — no access keys in pipeline secrets:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-platform-tfstate-eus2-001"
    storage_account_name = "stplatformtf001"
    container_name       = "tfstate"
    key                  = "prod/platform/terraform.tfstate"
    use_oidc             = true
  }
}
```

Bootstrap module: [terraform/bootstrap/state-backend/](../terraform/bootstrap/state-backend/)

## State Locking

- Native blob leasing viaazurerm backend
- Stale lock (>30 min) requires Platform Lead approval to break
- See [runbook.md](runbook.md#5-runbook-terraform-pipeline-failure)

## Break-Glass Procedure

1. Open SEV-2 incident ticket
2. Activate PIM role `Storage Blob Data Owner` (time-bound, max 4 hours)
3. Perform required state operation (import, unlock, restore from version)
4. Document action in ticket
5. Deactivate PIM role
6. Post-incident review within 24 hours

Break-glass is **never** used for normal `terraform apply` — pipeline OIDC only.

## Related

- [Platform Governance](platform-governance.md#4-remote-state--backend-access)
- [Security & Governance](security-governance.md)
