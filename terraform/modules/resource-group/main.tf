locals {
  mandatory_tags = {
    environment         = var.environment
    application         = var.application_name
    owner               = var.owner_email
    cost-center         = var.cost_center
    data-classification = var.data_classification
    managed-by          = "terraform"
    business-unit       = var.business_unit
  }

  tags = merge(local.mandatory_tags, var.additional_tags)
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = local.tags
}

resource "azurerm_management_lock" "this" {
  count = var.enable_management_lock ? 1 : 0

  name       = var.lock_name
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Platform-managed resource group. Deletion requires lock removal via IaC."
}
