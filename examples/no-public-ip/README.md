# No Public IP Standard

Documents how the platform prevents public IP assignment on workload VMs and how to handle exceptions.

## Standard

- Workload VMs use **private IP only**
- No `azurerm_public_ip` in standard deployment modules
- Remote access via **Azure Bastion**, VPN, or private jump hosts
- Azure Policy denies public IP on NICs in production (see [deny-public-ip.md](../../security/policy-examples/deny-public-ip.md))

## Module Behavior

The `linux-vm` module creates a network interface with dynamic private allocation only:

```hcl
resource "azurerm_network_interface" "this" {
  # ...

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public_ip_address_id — intentional
  }
}
```

There is no variable to enable public IP attachment by design.

## Anti-Pattern — Do Not Deploy

```hcl
# NOT APPROVED — violates platform standard
resource "azurerm_public_ip" "vm" {
  name                = "pip-vm-app-prod-eus2-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "bad_example" {
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.vm.id  # Blocked by policy in prod
  }
}
```

Policy effect: **Deny** at prod management group scope.

## Approved Access Pattern

```hcl
# Access via Bastion in hub — no workload public IP
data "azurerm_bastion_host" "hub" {
  name                = "bas-hub-eus2-001"
  resource_group_name = "rg-hub-network-eus2-001"
}

module "app_server" {
  source = "../../terraform/modules/linux-vm"

  name      = "vm-app-prod-eus2-001"
  subnet_id = module.vnet.subnet_ids["snet-app-prod-eus2-001"]
  # Connect: Azure Portal → Bastion → VM private IP
}
```

## Security Exception

If public IP is unavoidable:

1. Open architecture exception ticket
2. Add entry to `security/access-management/users-groups.yml` → `exceptions`
3. Apply time-bound Azure Policy exemption
4. Restrict NSG to explicit source prefixes
5. Review monthly until removed

## Validation

Checkov / custom policy scan in CI flags `azurerm_public_ip` in workload paths:

```yaml
# .github/workflows/validation.yml — conceptual check
- name: Reject public IP resources
  run: |
    if rg -l 'azurerm_public_ip' terraform/modules/linux-vm terraform/environments/; then
      echo "Public IP resources found in workload modules"
      exit 1
    fi
```

## Related

- [Security & Governance](../../docs/security-governance.md)
- [Linux VM Standardization](../linux-vm-standardization/)
