output "id" {
  description = "Subnet ARM ID — pass to NSG associations, private endpoints, and VMs"
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "Subnet name"
  value       = azurerm_subnet.this.name
}

output "address_prefixes" {
  description = "Assigned address prefixes"
  value       = azurerm_subnet.this.address_prefixes
}

output "virtual_network_name" {
  description = "Parent virtual network name"
  value       = var.virtual_network_name
}
