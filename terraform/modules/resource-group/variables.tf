variable "name" {
  description = "Resource group name following naming convention: rg-{workload}-{env}-{region}-{seq}"
  type        = string

  validation {
    condition     = can(regex("^rg-[a-z0-9-]+$", var.name))
    error_message = "Resource group name must match pattern rg-{workload}-{env}-{region}-{seq}."
  }
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Deployment environment: dev, qa, prod, hub, shared"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod", "hub", "shared"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod, hub, shared."
  }
}

variable "cost_center" {
  description = "Cost center code for chargeback"
  type        = string
}

variable "owner_email" {
  description = "Team or individual responsible for resources in this group"
  type        = string
}

variable "application_name" {
  description = "Application or platform service identifier"
  type        = string
}

variable "data_classification" {
  description = "Data sensitivity classification"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
}

variable "business_unit" {
  description = "Business unit or division for chargeback and policy (business-unit tag)"
  type        = string
}

variable "additional_tags" {
  description = "Optional supplementary tags merged with mandatory platform tags"
  type        = map(string)
  default     = {}
}

variable "enable_management_lock" {
  description = "Apply CanNotDelete management lock (recommended for prod)"
  type        = bool
  default     = false
}

variable "lock_name" {
  description = "Name of the management lock when enabled"
  type        = string
  default     = "platform-cannot-delete"
}
