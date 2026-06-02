variable "name" {
  description = "Managed identity name: id-{workload}-{env}-{seq}"
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

variable "tags" {
  type = map(string)
}
