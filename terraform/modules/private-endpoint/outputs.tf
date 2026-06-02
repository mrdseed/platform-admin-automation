output "id" {
  description = "Private endpoint ARM ID"
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "Private endpoint name"
  value       = azurerm_private_endpoint.this.name
}

output "private_ip_address" {
  description = "Private IP allocated in the PE subnet"
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

output "network_interface_id" {
  description = "NIC ARM ID created for the private endpoint"
  value       = azurerm_private_endpoint.this.network_interface[0].id
}
