variable "name" {
  description = "Workspace name: law-{workload}-{env}-{region}-{seq}"
  type        = string
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

variable "sku" {
  type    = string
  default = "PerGB2018"
}

variable "retention_in_days" {
  type    = number
  default = 90
}

variable "daily_quota_gb" {
  type    = number
  default = -1
}

variable "internet_ingestion_enabled" {
  description = "Disable for private-only ingestion paths when using AMPLS"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Disable when query access is restricted to private endpoints"
  type        = bool
  default     = true
}

variable "enable_self_diagnostics" {
  description = "Ship workspace audit logs to itself (disable in minimal dev stacks)"
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}
