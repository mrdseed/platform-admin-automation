terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

variable "name" {
  description = "Storage account name (globally unique, no hyphens)"
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

variable "is_hns_enabled" {
  type    = bool
  default = false
}

variable "enable_sftp" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  description = "Must remain false for production workloads"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Disable in prod; use managed identity and local users for SFTP"
  type        = bool
  default     = false
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}
