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
