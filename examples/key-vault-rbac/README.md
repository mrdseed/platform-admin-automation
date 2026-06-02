# Key Vault RBAC Example

RBAC-only Key Vault deployment with private endpoint, managed identity access, and pipeline role separation.

## Role Matrix

| Principal | Role | Justification |
|-----------|------|---------------|
| `id-platform-tf-prod` (pipeline MI) | Key Vault Secrets Officer | Deploy and rotate secrets via IaC |
| `id-platform-app-prod-001` (workload MI) | Key Vault Secrets User | Runtime secret read |
| `grp-security-audit` (Entra group) | Key Vault Reader | Compliance audit — no secret read |
| Break-glass admin group | Key Vault Administrator | Emergency access — PIM eligible |

## Usage

```hcl
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-platform-app-prod-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = module.rg.tags
}

module "key_vault" {
  source = "../../terraform/modules/key-vault"

  name                = "kv-platform-prod-eus2-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = false
  purge_protection_enabled      = true

  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-pe-prod-eus2-001"]
  private_dns_zone_ids         = [data.azurerm_private_dns_zone.kv.id]

  rbac_assignments = {
    pipeline = {
      principal_id         = var.pipeline_principal_id
      role_definition_name = "Key Vault Secrets Officer"
    }
    application = {
      principal_id         = azurerm_user_assigned_identity.app.principal_id
      role_definition_name = "Key Vault Secrets User"
    }
    audit = {
      principal_id         = var.security_audit_group_object_id
      role_definition_name = "Key Vault Reader"
    }
  }

  tags = module.rg.tags
}
```

## Secret Naming Convention

```
{application}/{environment}/{secret-name}
```

Examples:
- `platform-sftp/prod/partner-inbound-sftp-key`
- `platform-app/prod/db-connection-string`

## Anti-Patterns (Do Not Use)

- Access policies instead of RBAC on new vaults
- Granting `Key Vault Administrator` to workload identities
- Public network access enabled in production
- Storing secrets in `terraform.tfvars` or Git

## Verification

```bash
# Confirm RBAC mode
az keyvault show -n kv-platform-prod-eus2-001 \
  --query "properties.enableRbacAuthorization"

# List role assignments (requires Reader on vault)
az role assignment list --scope $(az keyvault show -n kv-platform-prod-eus2-001 --query id -o tsv) -o table
```
