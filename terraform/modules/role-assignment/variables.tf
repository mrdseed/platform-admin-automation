terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

variable "assignments" {
  description = "RBAC role assignments — use scoped custom roles, not Contributor"
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
    description          = optional(string, "")
  }))
}

variable "denied_roles" {
  description = "Roles that must not be assigned via this module"
  type        = list(string)
  default     = ["Owner", "Contributor", "User Access Administrator"]

  validation {
    condition = alltrue([
      for a in var.assignments :
      !contains(var.denied_roles, a.role_definition_name)
    ])
    error_message = "Broad roles (Owner, Contributor, UAA) are not permitted. Use custom RBAC roles."
  }
}
