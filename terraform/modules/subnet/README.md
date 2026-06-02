# Subnet Module

Creates a subnet in an existing virtual network with optional service endpoints and delegation.

Subnets do not receive public IP addresses — workload exposure is controlled at the NSG and routing layers.

## Usage

```hcl
module "subnet_app" {
  source = "../../modules/subnet"

  name                 = "snet-app-prod-eus2-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.3.1.0/24"]
  environment          = "prod"

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
  ]
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Subnet ARM ID |
| name | Subnet name |
| address_prefixes | CIDR prefixes |

## Required RBAC

`PlatformDeploy-Network` custom role at resource group scope.
