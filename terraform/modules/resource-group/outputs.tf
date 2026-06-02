output "id" {
  description = "Resource group ARM ID"
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
  description = "Mandatory platform tags applied to the resource group — pass to downstream modules"
  value       = local.tags
}

output "management_lock_id" {
  description = "Management lock ID when enabled, otherwise null"
  value       = try(azurerm_management_lock.this[0].id, null)
}
