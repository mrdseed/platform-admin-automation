variable "name" {
  description = "Globally unique storage account name (3–24 lowercase alphanumeric characters, no hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "environment" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "GRS"
}

variable "account_kind" {
  type    = string
  default = "StorageV2"
}

variable "is_hns_enabled" {
  description = "Enable hierarchical namespace (required for SFTP / ADLS Gen2)"
  type        = bool
  default     = false
}

variable "enable_sftp" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  description = "Keep false for private-first workloads — pair with private-endpoint module"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Disable in production; prefer managed identity and RBAC"
  type        = bool
  default     = false
}

variable "allow_nested_items_to_be_public" {
  description = "Must remain false to prevent anonymous blob access"
  type        = bool
  default     = false
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "blob_delete_retention_days" {
  type    = number
  default = 7
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ARM ID for diagnostic settings"
  type        = string
  default     = null
}

variable "tags" {
  type = map(string)
}
