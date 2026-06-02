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
  description = "Private endpoint subnet (dedicated /27 recommended)"
  type        = string
}

variable "private_connection_resource_id" {
  description = "ARM ID of the target PaaS resource"
  type        = string
}

variable "subresource_names" {
  description = "Target subresource (vault, blob, table, sqlServer, etc.)"
  type        = list(string)
}

variable "connection_name" {
  type    = string
  default = null
}

variable "is_manual_connection" {
  type    = bool
  default = false
}

variable "private_dns_zone_ids" {
  type    = list(string)
  default = []
}

variable "dns_zone_group_name" {
  type    = string
  default = null
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}
