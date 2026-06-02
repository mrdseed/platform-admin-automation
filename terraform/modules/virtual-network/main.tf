resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count = var.peer_to_hub != null ? 1 : 0

  name                         = "peer-${var.name}-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peer_to_hub.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.peer_to_hub.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  count = var.peer_to_hub != null ? 1 : 0

  name                         = "peer-hub-to-${var.name}"
  resource_group_name          = var.peer_to_hub.hub_resource_group_name
  virtual_network_name         = var.peer_to_hub.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.peer_to_hub.allow_gateway_transit
}
