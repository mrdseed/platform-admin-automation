# Network Security Group Module

Creates an NSG with optional rules and subnet associations. By default, denies inbound traffic from the Internet.

## Usage

```hcl
module "nsg_app" {
  source = "../../modules/network-security-group"

  name                = "nsg-app-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  subnet_ids          = [module.subnet_app.id]
  tags                = module.resource_group.tags

  enable_default_deny_internet = true

  security_rules = [
    {
      name                       = "AllowBastionSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.250.0/27"
      destination_address_prefix = "*"
      description                = "SSH from hub bastion subnet only"
    }
  ]
}
```

## Security Defaults

- `enable_default_deny_internet = true` adds priority 4096 deny rule for inbound Internet traffic
- No public IP is created by this module

## Required RBAC

`PlatformDeploy-Network` custom role.
