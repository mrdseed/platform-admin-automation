# Network Security Group Module

Creates an NSG with optional rules and subnet associations. Default posture: deny inbound from Internet unless rules are explicitly added.

## Usage

```hcl
module "nsg_app" {
  source = "../../modules/network-security-group"

  name                = "nsg-app-dev-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
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
      description                = "Deny direct inbound from Internet"
    }
  ]

  tags = local.platform_tags
}
```

## Required RBAC

`PlatformDeploy-Network` custom role — not Contributor.
