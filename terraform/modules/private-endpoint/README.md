# Private Endpoint Module

Generic private endpoint for Key Vault, Storage, and other PaaS services.

## Usage

```hcl
module "pe_key_vault" {
  source = "../../modules/private-endpoint"

  name                = "pe-kv-platform-dev-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  subnet_id           = module.subnet_pe.id

  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids             = var.private_dns_zone_keyvault_ids

  tags = local.platform_tags
}
```

## Required RBAC

`PlatformDeploy-Network` for endpoint; target resource deploy role for the connected service.
