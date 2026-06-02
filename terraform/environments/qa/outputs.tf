output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "linux_vm_private_ip" {
  value = module.linux_vm.private_ip_address
}
