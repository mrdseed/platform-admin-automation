variable "name" {
  description = "Virtual network name: vnet-{role}-{env}-eus2-{seq}"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the VNet"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "address_space" {
  description = "VNet address space CIDR blocks"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet definitions keyed by subnet name"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}

variable "hub_firewall_private_ip" {
  description = "Private IP of Azure Firewall for default route (spoke UDR). Null for hub VNets."
  type        = string
  default     = null
}

variable "peer_to_hub" {
  description = "Hub VNet ID for spoke peering configuration"
  type = object({
    hub_vnet_id                 = string
    hub_resource_group_name     = string
    hub_vnet_name               = string
    allow_gateway_transit       = optional(bool, true)
    use_remote_gateways         = optional(bool, true)
  })
  default = null
}

variable "dns_servers" {
  description = "Custom DNS servers (hub private DNS forwarder IPs)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags inherited from parent RG or module caller"
  type        = map(string)
  default     = {}
}
