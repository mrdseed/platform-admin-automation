variable "name" {
  description = "VM name: vm-{app}-{env}-eus2-{seq}"
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
  description = "Subnet ID for VM network interface"
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local admin username (SSH key auth only)"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key for admin access"
  type        = string
  sensitive   = true
}

variable "source_image_reference" {
  description = "OS image reference"
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
  description = "User-assigned managed identity IDs to attach to VM"
  type        = list(string)
  default     = []
}

variable "cloud_init_data" {
  description = "cloud-config content for custom data (base64 encoded by provider)"
  type        = string
  default     = null
}

variable "enable_azure_monitor_agent" {
  type    = bool
  default = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for AMA"
  type        = string
  default     = null
}

variable "enable_trusted_launch" {
  description = "Enable Secure Boot and vTPM"
  type        = bool
  default     = true
}

variable "patch_assessment_mode" {
  description = "Azure Update Manager assessment mode"
  type        = string
  default     = "AutomaticByPlatform"
}

variable "tags" {
  type    = map(string)
  default = {}
}
