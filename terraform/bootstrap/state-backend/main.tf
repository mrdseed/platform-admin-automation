terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "../../modules/resource-group"

  name                = "rg-platform-tfstate-eus2-001"
  location            = var.location
  environment         = "shared"
  cost_center         = var.cost_center
  owner_email         = var.owner_email
  application_name    = "platform-tfstate"
  business_unit       = var.business_unit
  data_classification = "internal"

  enable_management_lock = true
}

resource "azurerm_storage_account" "tfstate" {
  name                             = var.storage_account_name
  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = false
  shared_access_key_enabled        = var.enable_shared_key_access
  allow_nested_items_to_be_public  = false
  blob_properties {
    versioning_enabled  = true
    delete_retention_policy { days = 30 }
  }
  tags = module.resource_group.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "azurerm_management_lock" "storage" {
  count = var.enable_storage_lock ? 1 : 0

  name       = "platform-tfstate-cannot-delete"
  scope      = azurerm_storage_account.tfstate.id
  lock_level = "CanNotDelete"
}

resource "azurerm_monitor_diagnostic_setting" "tfstate" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-tfstate"
  target_resource_id         = azurerm_storage_account.tfstate.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  metric { category = "AllMetrics" enabled = true }
}
