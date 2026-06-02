variable "environment" {
  description = "Deployment environment label"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Example supports dev, qa, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "cost_center" {
  type    = string
  default = "CC-1042"
}

variable "owner_email" {
  type    = string
  default = "platform-team@example.com"
}

variable "business_unit" {
  type    = string
  default = "engineering"
}

variable "vnet_address_space" {
  description = "Spoke VNet CIDR — isolated from hub in this standalone example"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_app_prefix" {
  type    = string
  default = "10.10.1.0/24"
}

variable "subnet_pe_prefix" {
  type    = string
  default = "10.10.240.0/27"
}

variable "bastion_subnet_prefix" {
  description = "Hub bastion subnet CIDR for NSG SSH rule; null to omit allow rule"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "Globally unique storage account name"
  type        = string
  default     = "stplatbaseline001"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "pipeline_object_id" {
  description = "Object ID of deployment pipeline principal"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM admin access"
  type        = string
  sensitive   = true
}

variable "private_dns_zone_keyvault_id" {
  type    = string
  default = null
}

variable "private_dns_zone_blob_id" {
  type    = string
  default = null
}
