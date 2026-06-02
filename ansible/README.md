# Ansible — Linux Hardening & Image Lifecycle

Ansible playbooks for baseline hardening, SSH configuration, audit logging, and post-build validation of Linux platform images.

## Image Lifecycle

| Phase | Location | Output |
|-------|----------|--------|
| Build | Ephemeral VM from marketplace base image | Unhardened instance |
| Harden | `playbooks/baseline-hardening.yml` + role `linux-baseline` | CIS-aligned configuration |
| Validate | `playbooks/validate-image.yml` | Pass/fail report |
| Capture | Azure CLI / Packer | Compute Gallery image version |
| Promote | Pipeline per environment | Dev → QA → Prod gallery replication |

### Promotion Flow

1. **Dev** — run playbooks against build VM; capture image `img-platform-ubuntu2204-dev-v{version}`
2. **QA** — deploy VM from dev image; run `validate-image.yml`; security sign-off
3. **Prod** — replicate approved image version; update Terraform `source_image_reference` or gallery ID

Manual SSH changes on golden images are **not allowed** — rebuild from playbooks.

## Prerequisites

```bash
pip install ansible-core
ansible-galaxy collection install ansible.posix community.general
```

Target hosts via dynamic inventory or `--limit` for build VM private IP (reachable from bastion or pipeline runner on hub network).

## Playbooks

| Playbook | Purpose |
|----------|---------|
| [baseline-hardening.yml](playbooks/baseline-hardening.yml) | Full baseline via `linux-baseline` role |
| [ssh-hardening.yml](playbooks/ssh-hardening.yml) | SSH-only hardening (subset / re-run) |
| [audit-logging.yml](playbooks/audit-logging.yml) | auditd + rsyslog forwarding |
| [validate-image.yml](playbooks/validate-image.yml) | Post-hardening assertions |

## Usage

From bastion or CI runner with network path to build VM:

```bash
cd ansible

# Full hardening
ansible-playbook -i inventory/build.yml playbooks/baseline-hardening.yml

# Validate before capture
ansible-playbook -i inventory/build.yml playbooks/validate-image.yml
```

### CI Integration (Concept)

```yaml
# GitHub Actions job excerpt
- name: Harden build VM
  run: ansible-playbook -i ansible/inventory/build.yml ansible/playbooks/baseline-hardening.yml
- name: Validate image
  run: ansible-playbook -i ansible/inventory/build.yml ansible/playbooks/validate-image.yml
```

## Inventory

Create `inventory/build.yml` at runtime (not committed with secrets):

```yaml
all:
  hosts:
    vm-image-build-001:
      ansible_host: 10.1.50.4
      ansible_user: azureadmin
      ansible_ssh_private_key_file: ~/.ssh/image-build
```

## Security Notes

- Playbooks do not embed passwords or keys — use vault or pipeline secrets
- SSH hardening disables root login and password authentication
- Validation playbook fails the pipeline if unexpected listeners or public-facing config detected

## Related

- [Security & Governance](../docs/security-governance.md)
- [Linux VM Standardization](../examples/linux-vm-standardization/)
- [Operational Runbook](../docs/runbook.md)
