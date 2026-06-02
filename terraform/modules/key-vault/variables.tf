variable "name" {
  description = "Key Vault name: kv-{app}-{env}-eus2-{seq} (max 24 chars)"
  type        = string

  validation {
    condition     = length(var.name) <= 24
    error_message = "Key Vault name must be 24 characters or fewer."
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

variable "tenant_id" {
  description = "Azure Entra ID tenant ID — supplied via variable, never hardcoded"
  type        = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  description = "Must be false for production — use private-endpoint module"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}
