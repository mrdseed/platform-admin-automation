locals {
  public_access_blocked = !var.public_network_access_enabled
}

resource "azurerm_storage_account" "this" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  account_kind                     = var.account_kind
  is_hns_enabled                   = var.is_hns_enabled
  sftp_enabled                     = var.enable_sftp
  public_network_access_enabled    = var.public_network_access_enabled
  shared_access_key_enabled        = var.shared_access_key_enabled
  allow_nested_items_to_be_public  = var.allow_nested_items_to_be_public
  min_tls_version                  = var.min_tls_version
  tags                             = var.tags

  dynamic "network_rules" {
    for_each = local.public_access_blocked ? [1] : []

    content {
      default_action = "Deny"
      bypass         = ["AzureServices"]
    }
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
