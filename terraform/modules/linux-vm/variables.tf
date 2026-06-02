variable "name" {
  description = "VM name: vm-{app}-{env}-{region}-{seq}"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "subnet_id" {
  description = "Private subnet ID — VM receives no public IP"
  type        = string
}

variable "private_ip_address" {
  description = "Optional static private IP; null for dynamic allocation"
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Azure VM SKU"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local admin username (SSH key authentication only)"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key — supplied via pipeline variable, never hardcoded"
  type        = string
  sensitive   = true
}

variable "source_image_reference" {
  description = "Marketplace or gallery image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "Premium_LRS"
}

variable "os_disk_size_gb" {
  type    = number
  default = 128
}

variable "user_assigned_identity_ids" {
  description = "User-assigned managed identity resource IDs to attach"
  type        = list(string)
  default     = []
}

variable "cloud_init_data" {
  description = "cloud-config payload applied at first boot"
  type        = string
  default     = null
}

variable "enable_azure_monitor_agent" {
  type    = bool
  default = true
}

variable "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID (workspace_id output) for Azure Monitor Agent"
  type        = string
  default     = null
}

variable "enable_trusted_launch" {
  description = "Enable Secure Boot and vTPM (Trusted Launch)"
  type        = bool
  default     = true
}

variable "patch_assessment_mode" {
  type    = string
  default = "AutomaticByPlatform"
}

variable "tags" {
  description = "Platform tags from resource group module"
  type        = map(string)
}
