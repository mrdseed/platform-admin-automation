# Route Table Module

User-defined routes for spoke subnets (e.g. default route via Azure Firewall).

## Usage

```hcl
module "route_table_spoke" {
  source = "../../modules/route-table"

  name                = "udr-spoke-dev-eus2-default"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  subnet_ids          = [module.subnet_app.id, module.subnet_pe.id]

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.hub_firewall_private_ip
    }
  ]

  tags = local.platform_tags
}
```
