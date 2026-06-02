locals {
  mandatory_tags = {
    Environment        = var.environment
    CostCenter         = var.cost_center
    Owner              = var.owner_email
    Application        = var.application_name
    ManagedBy          = "terraform"
    DataClassification = var.data_classification
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
  notes      = "Managed by platform-admin-automation. Prevents accidental deletion."
}
