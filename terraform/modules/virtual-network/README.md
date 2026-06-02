# Virtual Network Module

Hub or spoke virtual network with optional bidirectional hub peering.

Compose subnets, NSGs, and route tables using dedicated modules — this module intentionally does not create them to keep responsibilities separated.

## Usage

```hcl
module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = "vnet-spoke-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  address_space       = ["10.3.0.0/16"]
  dns_servers         = ["10.0.2.4"]
  tags                = module.resource_group.tags

  peer_to_hub = {
    hub_vnet_id             = var.hub_vnet_id
    hub_resource_group_name = "rg-hub-network-eus2-001"
    hub_vnet_name           = "vnet-hub-eus2-001"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | VNet ARM ID |
| name | VNet name (required by subnet module) |
| peering_spoke_to_hub_id | Peering ID when configured |

## Required RBAC

`PlatformDeploy-Network`
