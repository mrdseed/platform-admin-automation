variable "name" {
  description = "Route table name: udr-{scope}-{env}-{region}-{seq}"
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

variable "bgp_route_propagation_enabled" {
  type    = bool
  default = false
}

variable "routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

variable "subnet_ids" {
  description = "Subnets to associate with this route table"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(string)
}
