# Custom RBAC Role Definitions

Scoped Azure RBAC roles for platform deployment service principals and pipeline managed identities. These roles replace broad **Contributor** or **Owner** assignments.

## Role Catalog

| File | Role Name | Scope | Purpose |
|------|-----------|-------|---------|
| [deployment-sp-network-role.json](deployment-sp-network-role.json) | `PlatformDeploy-Network` | RG / Sub | VNets, subnets, NSGs, peering, UDRs, private DNS links |
| [deployment-sp-compute-role.json](deployment-sp-compute-role.json) | `PlatformDeploy-Compute` | RG | VMs, extensions, managed identities, availability sets |
| [deployment-sp-keyvault-role.json](deployment-sp-keyvault-role.json) | `PlatformDeploy-KeyVault` | RG | Key Vault resources, private endpoints (vault subresource) |
| [deployment-sp-storage-role.json](deployment-sp-storage-role.json) | `PlatformDeploy-Storage` | RG | Storage accounts, SFTP config, blob PE |
| [deployment-sp-monitoring-role.json](deployment-sp-monitoring-role.json) | `PlatformDeploy-Monitoring` | RG / Sub | Diagnostic settings, DCR associations, alert rules |

## Why Custom Roles Instead of Contributor?

**Contributor** includes permissions to create, modify, and delete virtually all resource types in scope, read sensitive configuration, and in some scenarios facilitate privilege escalation when combined with other gaps.

Custom roles follow **least privilege**:

1. **Explicit Actions only** — Terraform modules declare required resource providers; roles mirror those Actions
2. **No delete on stateful data** — storage and Key Vault delete actions excluded from routine deploy roles; break-glass uses separate principal
3. **Separation of duties** — network changes and Key Vault secret data-plane access use different principals
4. **Auditable scope** — role names appear in activity logs; easier to review than generic Contributor

## Deployment

Replace `{subscription-id}` and assignable scope before deployment:

```bash
SUBSCRIPTION_ID="a1c0e000-0000-4000-8000-ac0000000000"
RG_SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/rg-platform-shared-prod-eus2-001"

for role_file in deployment-sp-*.json; do
  az role definition create --role-definition "$role_file"
done

PIPELINE_SP_OBJECT_ID="a1c0e002-0003-4000-8000-ac0000000002"

az role assignment create \
  --assignee-object-id "$PIPELINE_SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "PlatformDeploy-Network" \
  --scope "$RG_SCOPE"
```

## Role Assignment for RBAC Changes

Creating `azurerm_role_assignment` in Terraform requires one of:

- `Microsoft.Authorization/roleAssignments/write` on scope — included in deploy roles where needed
- Pre-created assignments by identity team (preferred for prod)
- Separate bootstrap principal with `User Access Administrator` used only during initial landing zone setup

## Review Checklist

- [ ] AssignableScopes limited to required subscription or resource groups
- [ ] No `*` Actions unless justified and documented
- [ ] DataActions granted only on storage/Key Vault deploy roles where Terraform manages data-plane resources
- [ ] Prod pipeline principal cannot assign Owner or User Access Administrator
- [ ] Roles reviewed quarterly with access review export
