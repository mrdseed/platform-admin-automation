output "id" {
  description = "Storage account ARM ID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint — use with private DNS when PE is configured"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key — null when shared_access_key_enabled is false"
  value       = var.shared_access_key_enabled ? azurerm_storage_account.this.primary_access_key : null
  sensitive   = true
}
