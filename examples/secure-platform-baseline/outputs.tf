output "resource_group_name" {
  description = "Deployed resource group"
  value       = module.resource_group.name
}

output "virtual_network_id" {
  value = module.virtual_network.id
}

output "log_analytics_workspace_id" {
  description = "ARM ID for diagnostic settings"
  value       = module.log_analytics.id
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
  description = "Private IP only — no public IP assigned"
  value       = module.linux_vm.private_ip_address
}

output "private_endpoint_ips" {
  description = "Private endpoint IPs in the PE subnet"
  value = {
    key_vault = module.private_endpoint_key_vault.private_ip_address
    storage   = module.private_endpoint_storage.private_ip_address
  }
}

output "role_assignment_ids" {
  value = module.role_assignments.ids
}
