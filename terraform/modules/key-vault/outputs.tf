output "id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "Key Vault URI for secret references"
  value       = azurerm_key_vault.this.vault_uri
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "private_endpoint_id" {
  description = "Private endpoint ID if deployed"
  value       = try(azurerm_private_endpoint.this[0].id, null)
}
