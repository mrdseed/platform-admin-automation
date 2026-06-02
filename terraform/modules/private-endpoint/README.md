# Private Endpoint Module

Generic Private Link endpoint for Key Vault, Storage, SQL, and other PaaS services.

## Usage

```hcl
module "pe_key_vault" {
  source = "../../modules/private-endpoint"

  name                = "pe-kv-platform-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  subnet_id           = module.subnet_pe.id
  tags                = module.resource_group.tags

  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids             = [var.private_dns_zone_keyvault_id]
}
```

## Subresource Names

| Service | subresource_names |
|---------|-------------------|
| Key Vault | `["vault"]` |
| Storage blob | `["blob"]` |
| Storage file | `["file"]` |

## Outputs

| Name | Description |
|------|-------------|
| private_ip_address | IP in PE subnet |
| id | Private endpoint ARM ID |

## Required RBAC

`PlatformDeploy-Network`
