variable "name" {
  description = "Subnet name following convention: snet-{purpose}-{env}-{region}-{seq}"
  type        = string

  validation {
    condition     = can(regex("^snet-[a-z0-9-]+$", var.name))
    error_message = "Subnet name should match snet-{purpose}-{env}-{region}-{seq}."
  }
}

variable "resource_group_name" {
  description = "Resource group containing the parent virtual network"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the parent virtual network"
  type        = string
}

variable "address_prefixes" {
  description = "CIDR blocks for the subnet — size per platform standards (/24 app, /27 PE)"
  type        = list(string)

  validation {
    condition     = length(var.address_prefixes) > 0
    error_message = "At least one address prefix is required."
  }
}

variable "service_endpoints" {
  description = "PaaS service endpoints enabled on the subnet (e.g. Microsoft.KeyVault, Microsoft.Storage)"
  type        = list(string)
  default     = []
}

variable "delegation" {
  description = "Optional subnet delegation for PaaS services (AKS, App Service, etc.)"
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
  default = null
}

variable "environment" {
  description = "Deployment environment for documentation and validation"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod", "hub", "shared"], var.environment)
    error_message = "Environment must be dev, qa, prod, hub, or shared."
  }
}
