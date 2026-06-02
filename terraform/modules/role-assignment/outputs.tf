output "ids" {
  description = "Map of assignment key to role assignment ARM ID"
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "principal_ids" {
  description = "Distinct principal IDs that received assignments"
  value       = distinct([for a in var.assignments : a.principal_id])
}
