variable "assignments" {
  description = "RBAC role assignments — use scoped roles, never Owner or Contributor"
  type = map(object({
    scope                            = string
    role_definition_name             = string
    principal_id                     = string
    principal_type                   = optional(string)
    description                      = optional(string, "")
    skip_service_principal_aad_check = optional(bool, false)
  }))
  default = {}
}

variable "denied_roles" {
  description = "Built-in broad roles blocked by validation"
  type        = list(string)
  default     = ["Owner", "Contributor", "User Access Administrator"]

  validation {
    condition = alltrue([
      for a in var.assignments :
      !contains(var.denied_roles, a.role_definition_name)
    ])
    error_message = "Broad roles (Owner, Contributor, UAA) are not permitted. Use custom RBAC roles from security/custom-rbac/."
  }
}
