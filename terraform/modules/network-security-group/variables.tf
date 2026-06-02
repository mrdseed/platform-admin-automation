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
  description = "NSG name: nsg-{purpose}-{env}-{region}-{seq}"
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

variable "subnet_ids" {
  description = "Subnet IDs to associate with this NSG"
  type        = list(string)
  default     = []
}

variable "security_rules" {
  description = "Inbound/outbound NSG rules"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = string
    destination_port_range       = string
    source_address_prefix        = string
    destination_address_prefix   = string
    description                  = optional(string, "")
  }))
  default = []
}

variable "tags" {
  type = map(string)
}
