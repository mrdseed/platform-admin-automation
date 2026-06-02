output "id" {
  description = "NSG ARM ID"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "NSG name"
  value       = azurerm_network_security_group.this.name
}

output "rule_ids" {
  description = "Map of rule name to rule resource ID"
  value       = { for k, v in azurerm_network_security_rule.this : k => v.id }
}

output "associated_subnet_ids" {
  description = "Subnet IDs associated with this NSG"
  value       = var.subnet_ids
}
