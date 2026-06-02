# Virtual Network Module

Deploys a hub or spoke virtual network with optional bidirectional peering to a hub.

Subnets, NSGs, and route tables are composed using dedicated modules: [subnet](../subnet/), [network-security-group](../network-security-group/), [route-table](../route-table/).

## Usage

```hcl
module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = "vnet-spoke-dev-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.0.2.4"]

  peer_to_hub = {
    hub_vnet_id             = var.hub_vnet_id
    hub_resource_group_name = "rg-hub-network-eus2-001"
    hub_vnet_name           = "vnet-hub-eus2-001"
  }

  tags = local.platform_tags
}
```

## Required RBAC

`PlatformDeploy-Network` custom role.
