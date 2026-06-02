output "ids" {
  value = { for k, v in azurerm_role_assignment.this : k => v.id }
}
