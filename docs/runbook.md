# Platform Operations Runbook

## Document Control

| Field | Value |
|-------|-------|
| Version | 2.0 |
| On-Call Rotation | PagerDuty — `platform-eng-primary` |
| Escalation | `#platform-ops` Slack → Platform Lead → Cloud Architect |

---

## 1. Incident Severity Classification

| Severity | Definition | Response Target | Examples |
|----------|------------|-----------------|----------|
| **SEV-1** | Production down or data breach | 15 min acknowledge, 1 hr mitigate | Prod hub firewall failure, Key Vault purge, SFTP data exfiltration alert |
| **SEV-2** | Degraded production or blocked release | 30 min acknowledge, 4 hr mitigate | QA pipeline auth failure, spoke peering broken |
| **SEV-3** | Non-prod impact or planned work issue | Next business day | Dev drift detected, failed scheduled patch |
| **SEV-4** | Informational / tech debt | Backlog | Policy compliance warning, tag missing on dev RG |

---

## 2. Initial Triage Checklist

When paged or receiving an alert:

1. **Acknowledge** the PagerDuty incident within SLA
2. **Identify scope** — hub vs spoke vs single workload (check Azure Service Health)
3. **Check recent changes** — GitHub Actions / GitLab pipeline runs in last 2 hours
4. **Open war room** for SEV-1/2: `#incident-{YYYYMMDD}-{short-name}`
5. **Document** timeline in incident ticket (Jira `PLAT-XXXX`)

### Quick Health Commands

```bash
# Verify Azure CLI context
az account show --query "{name:name, id:id, user:user.name}"

# Hub firewall health
az network firewall show -g rg-hub-network-eus2-001 -n afw-hub-eus2-001 \
  --query "provisioningState"

# Peering status (replace env)
az network vnet peering list \
  -g rg-spoke-prod-network-eus2-001 \
  --vnet-name vnet-spoke-prod-eus2-001 \
  -o table

# Key Vault availability (RBAC — use your operator identity)
az keyvault show -n kv-platform-prod-eus2-001 --query "properties.provisioningState"

# SFTP endpoint (from jump host with PE DNS resolution)
sftp -i ~/.ssh/platform_ops user@sftp.internal.example
```

---

## 3. Runbook: Hub Firewall Unavailable

**Symptoms:** Spoke workloads lose outbound connectivity; Azure Monitor alert `FirewallHealthProbeFailed`

**Impact:** All spoke egress blocked; inbound via App Gateway / ILB may still work

### Steps

1. Confirm firewall resource state in portal or CLI (see above)
2. Check Azure Service Health for East US 2 networking incidents
3. Review recent Terraform apply on `terraform/environments/prod` — firewall module changes
4. If misconfiguration:
   ```bash
   cd terraform/environments/prod
   tofu plan -var-file=terraform.tfvars -target=module.hub.module.firewall
   # Do NOT apply without second reviewer on SEV-1
   ```
5. If Azure platform issue: open support ticket **Severity A** for production
6. **Temporary mitigation** (break-glass, requires Cloud Architect approval):
   - Attach temporary UDR bypass route on affected spoke (document in ticket)
   - Never leave bypass in place > 4 hours

**Recovery verification:** Run synthetic probe from `vm-probe-prod-eus2-001` to `https://api.internal.example/health`

---

## 4. Runbook: Key Vault Access Failure

**Symptoms:** Applications report `403 Forbidden` on secret retrieval; MI authentication errors in App Insights

### Steps

1. Identify vault: `kv-{app}-{env}-eus2-{seq}`
2. Verify RBAC assignment still exists:
   ```bash
   MI_ID=$(az identity show -g rg-platform-sftp-prod-eus2-001 -n id-platform-sftp-prod-001 --query id -o tsv)
   az role assignment list --assignee "$MI_ID" --scope "/subscriptions/.../vaults/kv-platform-prod-eus2-001" -o table
   ```
3. Check private endpoint DNS resolution from affected subnet
4. Verify soft-delete / purge protection status — **never purge production vaults**
5. If role assignment missing: re-apply Terraform or restore from IaC state
6. Rotate affected secrets if unauthorized access suspected (SEV-1 security incident)

---

## 5. Runbook: Terraform Pipeline Failure

**Symptoms:** GitHub Actions `validation.yml` or environment apply job failed

### Common Causes

| Error | Resolution |
|-------|------------|
| `AuthorizationFailed` on role assignment | Pipeline SPN missing `User Access Administrator` or custom role not deployed |
| `409 Conflict` state lock | Check `stplatformtf001` lease; release if stale (>30 min) after verifying no active apply |
| `InvalidResourceReference` | Dependency ordering — ensure hub deploys before spoke peering module |
| OIDC token failure | Verify federated credential subject matches repo/branch |

### State Lock Release (use with caution)

```bash
az storage blob lease break \
  --account-name stplatformtf001 \
  --container-name tfstate \
  --blob-name prod/network/terraform.tfstate
```

Requires Platform Lead approval unless lock holder is confirmed crashed.

---

## 6. Runbook: SFTP Platform Incident

**Symptoms:** Partner cannot connect; authentication failures; storage throttling alerts

### Steps

1. Check storage account `stplatformsftpprod001` — health, metrics (Transactions, Egress)
2. Review SFTP authentication logs in Log Analytics:
   ```kusto
   StorageBlobLogs
   | where TimeGenerated > ago(1h)
   | where OperationName contains "Sftp"
   | where StatusText != "Success"
   | summarize count() by CallerIpAddress, StatusText
   ```
3. Verify private endpoint and DNS A-record in `privatelink.blob.core.windows.net` zone
4. Confirm local user not disabled: `az storage account local-user show ...`
5. For capacity: review lifecycle policy; engage storage team if > 80% capacity

### Partner Onboarding (standard change)

1. Create local user via Terraform module or approved pipeline job
2. Assign container-scoped permissions only
3. Provide partner with hostname, username, SSH key fingerprint — **never share account keys**
4. Update CMDB entry in ServiceNow `CHG-XXXXX`

---

## 7. Runbook: Linux VM Patching Failure

**Symptoms:** Azure Update Manager reports failed maintenance run; VM unreachable

### Steps

1. Check maintenance configuration assignment: `mc-linux-prod-eus2-monthly`
2. Review VM extension status:
   ```bash
   az vm extension list -g rg-app-prod-eus2-001 -vm vm-app-prod-eus2-003 -o table
   ```
3. Connect via Azure Bastion (not direct SSH from internet)
4. Inspect `/var/log/unattended-upgrades/` or `dnf history` depending on OS
5. If kernel update requires reboot: coordinate with app owner maintenance window
6. Re-run maintenance run after remediation

---

## 8. Deployment Procedures

### Standard Promotion Path

```
dev (auto apply on merge) → qa (manual approval) → prod (change ticket + 2 approvals)
```

### Pre-Apply Checklist (QA / Prod)

- [ ] `tofu plan` reviewed and attached to change ticket
- [ ] No unplanned destroys on stateful resources
- [ ] Rollback plan documented (previous commit SHA)
- [ ] Stakeholders notified in `#releases`

### Rollback

1. Revert Git commit on release branch
2. Pipeline applies previous known-good state
3. For stateful emergencies: restore from state versioning + targeted `tofu import` if needed
4. Post-incident review within 5 business days for SEV-1/2

---

## 9. Operational Governance

| Activity | Standard |
|----------|----------|
| Production change | Pull request + pipeline apply only — no portal |
| Approval | 2 reviewers + change ticket for prod |
| Validation | [validation.yml](../.github/workflows/validation.yml) must pass |
| Access change | PR to [users-groups.yml](../security/access-management/users-groups.yml) |
| State access | Pipeline OIDC only — break-glass per [backend-state-governance.md](backend-state-governance.md) |
| Drift | Corrected on next pipeline run or treated as incident |

Full framework: [Platform Governance](platform-governance.md#8-operational-governance)

---

## 10. Contacts

| Role | Contact |
|------|---------|
| Platform On-Call | PagerDuty `platform-eng-primary` |
| Cloud Architect | cloud-arch@example.com |
| Security Operations | secops@example.com |
| Azure Support | CSP portal — support contract on file |

---

## 11. Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-03-15 | Platform Engineering | Added SFTP runbook section |
| 2026-05-01 | Platform Engineering | Updated OIDC pipeline troubleshooting |
| 2026-06-01 | Platform Engineering | Consolidated firewall and KV procedures |
