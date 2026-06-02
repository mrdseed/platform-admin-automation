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
  description = "Subnet name: snet-{purpose}-{env}-{region}-{seq}"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "service_endpoints" {
  type    = list(string)
  default = []
}

variable "delegation" {
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
  type = string

  validation {
    condition     = contains(["dev", "qa", "prod", "hub", "shared"], var.environment)
    error_message = "Environment must be dev, qa, prod, hub, or shared."
  }
}

variable "tags" {
  type = map(string)
}
