resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_route_table" "spoke_default" {
  count = var.hub_firewall_private_ip != null ? 1 : 0

  name                          = "udr-${var.name}-default"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = var.tags
}

resource "azurerm_route" "default_to_firewall" {
  count = var.hub_firewall_private_ip != null ? 1 : 0

  name                   = "route-default-via-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.spoke_default[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "spoke_default" {
  for_each = var.hub_firewall_private_ip != null ? var.subnets : {}

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.spoke_default[0].id
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
