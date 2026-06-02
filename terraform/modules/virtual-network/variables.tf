variable "name" {
  description = "Virtual network name: vnet-{role}-{env}-eus2-{seq}"
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

  validation {
    condition     = contains(["dev", "qa", "prod", "hub", "shared"], var.environment)
    error_message = "Environment must be dev, qa, prod, hub, or shared."
  }
}

variable "address_space" {
  type = list(string)
}

variable "peer_to_hub" {
  description = "Hub VNet ID for spoke peering configuration"
  type = object({
    hub_vnet_id             = string
    hub_resource_group_name = string
    hub_vnet_name               = string
    allow_gateway_transit       = optional(bool, true)
    use_remote_gateways         = optional(bool, true)
  })
  default = null
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}
