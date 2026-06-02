variable "subscription_id" {
  description = "Azure subscription ID for dev workloads"
  type        = string
}

variable "tenant_id" {
  description = "Azure Entra ID tenant ID"
  type        = string
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
  description = "Hub VNet ID for spoke peering"
  type        = string
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
  description = "Central Log Analytics workspace resource ID"
  type        = string
  default     = null
}

variable "pipeline_object_id" {
  description = "Object ID of Terraform pipeline service principal or managed identity"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for standardized Linux VMs"
  type        = string
  sensitive   = true
}
