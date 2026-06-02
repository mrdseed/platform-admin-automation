variable "location" {
  type    = string
  default = "eastus2"
}

variable "cost_center" {
  type    = string
  default = "CC-1042"
}

variable "owner_email" {
  type    = string
  default = "platform-team@acmecorp.com"
}

variable "business_unit" {
  type    = string
  default = "engineering"
}

variable "storage_account_name" {
  description = "Globally unique storage account name for Terraform state"
  type        = string
  default     = "stplatformtf001"
}

variable "enable_shared_key_access" {
  description = "Disable after pipeline RBAC is configured"
  type        = bool
  default     = false
}

variable "enable_storage_lock" {
  type    = bool
  default = true
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
