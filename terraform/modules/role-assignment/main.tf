resource "azurerm_role_assignment" "this" {
  for_each = var.assignments

  scope                            = each.value.scope
  role_definition_name             = each.value.role_definition_name
  principal_id                     = each.value.principal_id
  principal_type                   = try(each.value.principal_type, null)
  description                      = try(each.value.description, null)
  skip_service_principal_aad_check = try(each.value.skip_service_principal_aad_check, false)
}
