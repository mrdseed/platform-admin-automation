output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "subnet_app_id" {
  value = module.subnet_app.id
}

output "subnet_pe_id" {
  value = module.subnet_pe.id
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.id
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "managed_identity_principal_id" {
  value = module.app_identity.principal_id
}

output "linux_vm_private_ip" {
  value = module.linux_vm.private_ip_address
}

output "linux_vm_id" {
  value = module.linux_vm.id
}
