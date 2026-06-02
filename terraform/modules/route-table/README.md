# Route Table Module

User-defined routes for spoke subnets — typically default route via Azure Firewall.

## Usage

```hcl
module "route_table" {
  source = "../../modules/route-table"

  name                = "udr-spoke-prod-eus2-default"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  subnet_ids          = [module.subnet_app.id]
  tags                = module.resource_group.tags

  routes = [{
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.4"
  }]
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Route table ARM ID |
| route_names | Configured route names |

## Required RBAC

`PlatformDeploy-Network`
