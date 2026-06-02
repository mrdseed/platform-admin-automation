output "id" {
  description = "Virtual network ARM ID"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Virtual network name — required by subnet module"
  value       = azurerm_virtual_network.this.name
}

output "location" {
  description = "Azure region"
  value       = azurerm_virtual_network.this.location
}

output "address_space" {
  description = "Configured address space prefixes"
  value       = azurerm_virtual_network.this.address_space
}

output "peering_spoke_to_hub_id" {
  description = "Spoke-to-hub peering ID when peering is configured"
  value       = try(azurerm_virtual_network_peering.spoke_to_hub[0].id, null)
}
