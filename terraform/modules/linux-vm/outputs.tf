output "id" {
  description = "Linux VM resource ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "VM name"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Primary private IP address"
  value       = azurerm_network_interface.this.private_ip_address
}

output "network_interface_id" {
  description = "NIC resource ID"
  value       = azurerm_network_interface.this.id
}
