output "id" {
  description = "Route table ARM ID"
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Route table name"
  value       = azurerm_route_table.this.name
}

output "route_names" {
  description = "Names of configured routes"
  value       = keys(azurerm_route.this)
}

output "associated_subnet_ids" {
  description = "Subnets using this route table"
  value       = var.subnet_ids
}
