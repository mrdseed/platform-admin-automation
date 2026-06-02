# Virtual Network Module

Deploys hub or spoke virtual networks with subnets, NSG associations, optional UDR to Azure Firewall, and bidirectional VNet peering.

## Usage — Spoke

```hcl
module "vnet_spoke_prod" {
  source = "../../modules/virtual-network"

  name                = "vnet-spoke-prod-eus2-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = ["10.3.0.0/16"]

  hub_firewall_private_ip = "10.0.1.4"
  dns_servers             = ["10.0.2.4"]

  peer_to_hub = {
    hub_vnet_id             = data.terraform_remote_state.hub.outputs.vnet_id
    hub_resource_group_name = "rg-hub-network-eus2-001"
    hub_vnet_name           = "vnet-hub-eus2-001"
  }

  subnets = {
    snet-app-prod-eus2-001 = {
      address_prefixes  = ["10.3.1.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    snet-pe-prod-eus2-001 = {
      address_prefixes = ["10.3.240.0/27"]
    }
  }

  tags = module.rg.tags
}
```

## Notes

- NSG rules are intentionally minimal at module level; attach rules via separate `azurerm_network_security_rule` resources or policy
- Hub VNet should omit `hub_firewall_private_ip` and `peer_to_hub`
