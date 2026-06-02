variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "cost_center" {
  type    = string
  default = "CC-1042"
}

variable "owner_email" {
  type    = string
  default = "platform-team@example.com"
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_resource_group_name" {
  type    = string
  default = "rg-hub-network-eus2-001"
}

variable "hub_vnet_name" {
  type    = string
  default = "vnet-hub-eus2-001"
}

variable "hub_firewall_private_ip" {
  type    = string
  default = "10.0.1.4"
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "pipeline_object_id" {
  type = string
}

variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}
