# Bootstrap: Secure Terraform State Backend

One-time bootstrap stack for remote state storage. Deploy from a break-glass or bootstrap pipeline principal with subscription-level permissions, then restrict access to pipeline identities only.

## Resources Created

- Resource group `rg-platform-tfstate-eus2-001`
- Storage account with public access disabled
- Container `tfstate` with private access
- Optional management lock on resource group (prod)
- Diagnostic settings to central Log Analytics (when ID provided)

## Usage

```bash
cd terraform/bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars

tofu init
tofu plan
tofu apply
```

After bootstrap, configure environment backends to point at this storage account and grant pipeline MIs `Storage Blob Data Contributor` on the container.

## Security Defaults

- `public_network_access_enabled = false`
- `shared_access_key_enabled = false` (after pipeline RBAC configured)
- `min_tls_version = TLS1_2`
- `allow_nested_items_to_be_public = false`
- Versioning and soft delete enabled

## Related

- [Backend State Governance](../../../docs/backend-state-governance.md)
