data "azurerm_client_config" "current" {}

locals {
  environment          = "qa"
  application_name     = "platform-shared"
  region_code          = "eus2"
  instance             = "001"
  data_classification  = "internal"
  hub_firewall_enabled = var.hub_firewall_private_ip != null

}

# --- Resource Group ---

module "resource_group" {
  source = "../../modules/resource-group"

  name                = "rg-platform-shared-qa-eus2-001"
  location            = var.location
  environment         = local.environment
  cost_center         = var.cost_center
  owner_email         = var.owner_email
  application_name    = local.application_name
  business_unit       = var.business_unit
  data_classification = local.data_classification
}

# --- Observability ---

module "log_analytics" {
  source = "../../modules/log-analytics-workspace"

  name                = "law-platform-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  retention_in_days   = 60

  tags = module.resource_group.tags
}

# --- Network ---

module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = "vnet-spoke-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  address_space       = ["10.2.0.0/16"]
  dns_servers         = ["10.0.2.4"]

  peer_to_hub = {
    hub_vnet_id             = var.hub_vnet_id
    hub_resource_group_name = var.hub_resource_group_name
    hub_vnet_name           = var.hub_vnet_name
  }

  tags = module.resource_group.tags
}

module "subnet_app" {
  source = "../../modules/subnet"

  name                 = "snet-app-qa-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.2.1.0/24"]
  environment          = local.environment
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

module "subnet_pe" {
  source = "../../modules/subnet"

  name                 = "snet-pe-qa-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.2.240.0/27"]
  environment          = local.environment
}

module "network_security_group_app" {
  source = "../../modules/network-security-group"

  name                = "nsg-app-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_ids          = [module.subnet_app.id]

  security_rules = [
    {
      name                       = "DenyInboundInternet"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "No direct inbound from Internet"
    }
  ]

  tags = module.resource_group.tags
}

module "route_table_spoke" {
  source = "../../modules/route-table"

  name                = "udr-spoke-qa-eus2-default"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_ids          = [module.subnet_app.id, module.subnet_pe.id]

  routes = local.hub_firewall_enabled ? [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.hub_firewall_private_ip
    }
  ] : []

  tags = module.resource_group.tags
}

# --- Storage ---

module "storage_account" {
  source = "../../modules/storage-account"

  name                = "stplatformqa001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  log_analytics_workspace_id = module.log_analytics.id
  tags                       = module.resource_group.tags
}

# --- Identity ---

module "app_identity" {
  source = "../../modules/managed-identity"

  name                = "id-platform-app-qa-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
}

# --- Key Vault ---

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-platform-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  tenant_id           = var.tenant_id

  purge_protection_enabled      = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90
  log_analytics_workspace_id    = module.log_analytics.id

  tags = module.resource_group.tags
}

module "private_endpoint_key_vault" {
  source = "../../modules/private-endpoint"

  name                = "pe-kv-platform-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_id           = module.subnet_pe.id

  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids             = var.private_dns_zone_keyvault_id != null ? [var.private_dns_zone_keyvault_id] : []

  tags = module.resource_group.tags
}

module "private_endpoint_storage" {
  source = "../../modules/private-endpoint"

  name                = "pe-st-platform-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = local.environment
  subnet_id           = module.subnet_pe.id

  private_connection_resource_id = module.storage_account.id
  subresource_names              = ["blob"]
  private_dns_zone_ids             = var.private_dns_zone_blob_id != null ? [var.private_dns_zone_blob_id] : []

  tags = module.resource_group.tags
}

# --- RBAC (least privilege — no Contributor) ---

module "role_assignments" {
  source = "../../modules/role-assignment"

  assignments = {
    pipeline_keyvault = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets Officer"
      principal_id         = var.pipeline_object_id
      description          = "Pipeline secret management — qa"
    }
    app_keyvault = {
      scope                = module.key_vault.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.app_identity.principal_id
      description          = "Application runtime secret access"
    }
    app_storage = {
      scope                = module.storage_account.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = module.app_identity.principal_id
      description          = "Application blob read access"
    }
  }
}

# --- Compute (no public IP) ---

module "linux_vm" {
  source = "../../modules/linux-vm"

  name                = "vm-app-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.subnet_app.id

  vm_size        = "Standard_D2s_v5"
  ssh_public_key = var.admin_ssh_public_key

  user_assigned_identity_ids = [module.app_identity.id]
  log_analytics_workspace_guid = module.log_analytics.workspace_id

  tags = module.resource_group.tags
}



