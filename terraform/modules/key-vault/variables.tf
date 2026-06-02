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

variable "tenant_id" {
  description = "Azure Entra ID tenant ID"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU: standard or premium"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (required for prod)"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Allow public network access (should be false in prod)"
  type        = bool
  default     = false
}

variable "rbac_assignments" {
  description = "Map of RBAC role assignments on the vault"
  type = map(object({
    principal_id         = string
    role_definition_name = string
    description          = optional(string, "")
  }))
  default = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint (required when public access disabled)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for vault private link"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for diagnostic settings"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
