variable "name" {
  description = "NSG name: nsg-{purpose}-{env}-{region}-{seq}"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to associate with this NSG"
  type        = list(string)
  default     = []
}

variable "enable_default_deny_internet" {
  description = "When true, adds a low-priority deny rule for inbound Internet traffic"
  type        = bool
  default     = true
}

variable "security_rules" {
  description = "Custom NSG rules merged with optional default deny"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = optional(string, "")
  }))
  default = []
}

variable "tags" {
  description = "Platform tags from resource group module"
  type        = map(string)
}
