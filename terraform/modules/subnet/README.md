# Subnet Module

Creates a subnet within an existing virtual network.

## Usage

```hcl
module "subnet_app" {
  source = "../../modules/subnet"

  name                 = "snet-app-dev-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.1.1.0/24"]
  environment          = "dev"
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
  tags                 = local.platform_tags
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Subnet resource ID |
| name | Subnet name |
