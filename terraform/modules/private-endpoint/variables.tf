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
  description = "Private endpoint name: pe-{service}-{env}-{region}-{seq}"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "subnet_id" {
  type = string
}

variable "private_connection_resource_id" {
  type = string
}

variable "subresource_names" {
  type = list(string)
}

variable "private_dns_zone_ids" {
  type    = list(string)
  default = []
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}
