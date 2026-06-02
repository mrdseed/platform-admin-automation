output "id" {
  description = "Linux VM ARM ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "VM name"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Primary private IP — no public IP is assigned"
  value       = azurerm_network_interface.this.private_ip_address
}

output "network_interface_id" {
  description = "NIC ARM ID"
  value       = azurerm_network_interface.this.id
}

output "identity_ids" {
  description = "Attached user-assigned identity IDs"
  value       = var.user_assigned_identity_ids
}
