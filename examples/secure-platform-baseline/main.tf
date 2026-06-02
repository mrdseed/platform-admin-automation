terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

data "azurerm_client_config" "current" {}

locals {
  environment         = var.environment
  application_name    = "platform-baseline"
  data_classification = var.environment == "prod" ? "confidential" : "internal"
}

# -----------------------------------------------------------------------------
# Foundation
# -----------------------------------------------------------------------------

module "resource_group" {
  source = "../../terraform/modules/resource-group"

  name                = "rg-platform-baseline-${var.environment}-eus2-001"
  location            = var.location
  environment         = local.environment
  cost_center         = var.cost_center
  owner_email         = var.owner_email
  application_name    = local.application_name
  business_unit       = var.business_unit
  data_classification = local.data_classification

  enable_management_lock = var.environment == "prod"
}

module "log_analytics" {
  source = "../../terraform/modules/log-analytics-workspace"

  name                = "law-platform-baseline-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  retention_in_days   = var.log_retention_days
  tags                = module.resource_group.tags
}

# -----------------------------------------------------------------------------
# Network — private by default, no public IPs
# -----------------------------------------------------------------------------

module "virtual_network" {
  source = "../../terraform/modules/virtual-network"

  name                = "vnet-platform-baseline-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  address_space       = [var.vnet_address_space]
  tags                = module.resource_group.tags
}

module "subnet_app" {
  source = "../../terraform/modules/subnet"

  name                 = "snet-app-${var.environment}-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = [var.subnet_app_prefix]
  environment          = local.environment
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

module "subnet_pe" {
  source = "../../terraform/modules/subnet"

  name                 = "snet-pe-${var.environment}-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = [var.subnet_pe_prefix]
  environment          = local.environment
}

module "network_security_group_app" {
  source = "../../terraform/modules/network-security-group"

  name                = "nsg-app-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_ids          = [module.subnet_app.id]
  tags                = module.resource_group.tags

  enable_default_deny_internet = true

  security_rules = var.bastion_subnet_prefix != null ? [
    {
      name                       = "AllowBastionSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.bastion_subnet_prefix
      destination_address_prefix = "*"
      description                = "SSH from hub bastion subnet only"
    }
  ] : []
}

# -----------------------------------------------------------------------------
# Storage — private access, no anonymous blob
# -----------------------------------------------------------------------------

module "storage_account" {
  source = "../../terraform/modules/storage-account"

  name                = var.storage_account_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  tags                = module.resource_group.tags

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  log_analytics_workspace_id = module.log_analytics.id
}

module "private_endpoint_storage" {
  source = "../../terraform/modules/private-endpoint"

  name                = "pe-st-baseline-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_id           = module.subnet_pe.id
  tags                = module.resource_group.tags

  private_connection_resource_id = module.storage_account.id
  subresource_names              = ["blob"]
  private_dns_zone_ids             = var.private_dns_zone_blob_id != null ? [var.private_dns_zone_blob_id] : []
}

# -----------------------------------------------------------------------------
# Identity & secrets
# -----------------------------------------------------------------------------

module "app_identity" {
  source = "../../terraform/modules/managed-identity"

  name                = "id-platform-baseline-${var.environment}-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  tags                = module.resource_group.tags
}

module "key_vault" {
  source = "../../terraform/modules/key-vault"

  name                = "kv-base-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = module.resource_group.tags

  purge_protection_enabled      = var.environment == "prod"
  public_network_access_enabled = false
  soft_delete_retention_days    = var.environment == "dev" ? 7 : 90
  log_analytics_workspace_id    = module.log_analytics.id
}

module "private_endpoint_key_vault" {
  source = "../../terraform/modules/private-endpoint"

  name                = "pe-kv-baseline-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_id           = module.subnet_pe.id
  tags                = module.resource_group.tags

  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids             = var.private_dns_zone_keyvault_id != null ? [var.private_dns_zone_keyvault_id] : []
}

module "role_assignments" {
  source = "../../terraform/modules/role-assignment"

  assignments = {
    pipeline_keyvault = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets Officer"
      principal_id         = var.pipeline_object_id
      description          = "Pipeline secret management"
    }
    app_keyvault = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
      description          = "Runtime secret retrieval"
    }
    app_storage = {
      scope                = module.storage_account.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = module.app_identity.principal_id
      description          = "Read application blobs via private endpoint"
    }
  }
}

# -----------------------------------------------------------------------------
# Compute — private NIC only, no public IP
# -----------------------------------------------------------------------------

module "linux_vm" {
  source = "../../terraform/modules/linux-vm"

  name                = "vm-app-baseline-${var.environment}-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.subnet_app.id
  tags                = module.resource_group.tags

  vm_size        = var.vm_size
  ssh_public_key = var.ssh_public_key

  user_assigned_identity_ids   = [module.app_identity.id]
  log_analytics_workspace_guid = module.log_analytics.workspace_id
}
