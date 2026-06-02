output "resource_group_name" {
  value = module.resource_group.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  value = azurerm_storage_account.tfstate.id
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
