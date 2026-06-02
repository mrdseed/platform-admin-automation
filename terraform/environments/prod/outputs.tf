output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.virtual_network.vnet_id
}

output "subnet_ids" {
  value = module.virtual_network.subnet_ids
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "sftp_identity_id" {
  value = azurerm_user_assigned_identity.sftp.id
}

output "sftp_identity_principal_id" {
  value = azurerm_user_assigned_identity.sftp.principal_id
}
