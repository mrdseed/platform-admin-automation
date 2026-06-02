output "id" {
  description = "Key Vault ARM ID"
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "Key Vault URI for SDK and secret references"
  value       = azurerm_key_vault.this.vault_uri
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "rbac_authorization_enabled" {
  description = "Always true — this module does not support access policies"
  value       = azurerm_key_vault.this.enable_rbac_authorization
}
