output "id" {
  description = "Resource group resource ID"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.this.location
}

output "tags" {
  description = "Applied resource tags"
  value       = azurerm_resource_group.this.tags
}
