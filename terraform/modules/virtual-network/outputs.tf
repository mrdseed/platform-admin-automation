output "vnet_id" {
  description = "Virtual network resource ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "nsg_ids" {
  description = "Map of subnet name to NSG ID"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "route_table_id" {
  description = "Spoke default route table ID (null if hub VNet)"
  value       = try(azurerm_route_table.spoke_default[0].id, null)
}
