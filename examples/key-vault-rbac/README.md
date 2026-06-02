# Key Vault RBAC Example

RBAC-only Key Vault with private endpoint and role-assignment modules.

## Usage

```hcl
module "key_vault" {
  source = "../../terraform/modules/key-vault"

  name                = "kv-platform-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  tenant_id           = var.tenant_id

  public_network_access_enabled = false
  purge_protection_enabled      = true
  log_analytics_workspace_id    = module.log_analytics.id

  tags = local.platform_tags
}

module "private_endpoint_key_vault" {
  source = "../../terraform/modules/private-endpoint"

  name                = "pe-kv-platform-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  subnet_id           = module.subnet_pe.id

  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids             = [var.private_dns_zone_keyvault_id]

  tags = local.platform_tags
}

module "key_vault_rbac" {
  source = "../../terraform/modules/role-assignment"

  assignments = {
    pipeline = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets Officer"
      principal_id         = var.pipeline_object_id
    }
    application = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
    }
    audit = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Reader"
      principal_id         = var.security_audit_group_object_id
    }
  }
}
```

## Related

- [security/custom-rbac/](../../security/custom-rbac/)
- [role-assignment module](../../terraform/modules/role-assignment/)
