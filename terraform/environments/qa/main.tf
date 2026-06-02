data "azurerm_client_config" "current" {}

locals {
  environment      = "qa"
  application_name = "platform-shared"
}

module "resource_group" {
  source = "../../modules/resource-group"

  name                = "rg-platform-shared-qa-eus2-001"
  location            = var.location
  environment         = local.environment
  cost_center         = var.cost_center
  owner_email         = var.owner_email
  application_name    = local.application_name
  data_classification = "internal"
}

module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = "vnet-spoke-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.2.0.0/16"]
  dns_servers         = ["10.0.2.4"]

  hub_firewall_private_ip = var.hub_firewall_private_ip

  peer_to_hub = {
    hub_vnet_id             = var.hub_vnet_id
    hub_resource_group_name = var.hub_resource_group_name
    hub_vnet_name           = var.hub_vnet_name
  }

  subnets = {
    snet-app-qa-eus2-001 = {
      address_prefixes  = ["10.2.1.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    snet-pe-qa-eus2-001 = {
      address_prefixes = ["10.2.240.0/27"]
    }
  }

  tags = module.resource_group.tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-platform-qa-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = var.tenant_id

  purge_protection_enabled      = true
  public_network_access_enabled = false

  private_endpoint_subnet_id = module.virtual_network.subnet_ids["snet-pe-qa-eus2-001"]
  log_analytics_workspace_id = var.log_analytics_workspace_id

  rbac_assignments = {
    pipeline = {
      principal_id         = var.pipeline_object_id
      role_definition_name = "Key Vault Secrets Officer"
    }
  }

  tags = module.resource_group.tags
}
