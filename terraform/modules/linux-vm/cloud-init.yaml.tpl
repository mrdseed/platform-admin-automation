#cloud-config
# Platform baseline — linux-vm module default cloud-init reference
# Deploy from secure storage account; do not embed secrets in custom_data

package_update: true
package_upgrade: true

packages:
  - audispd-plugins
  - aide
  - fail2ban

write_files:
  - path: /etc/ssh/sshd_config.d/99-platform-hardening.conf
    permissions: "0644"
    content: |
      PasswordAuthentication no
      PermitRootLogin no
      MaxAuthTries 3
      ClientAliveInterval 300
      ClientAliveCountMax 2

runcmd:
  - systemctl restart sshd
  - systemctl enable fail2ban --now
  - aideinit || true

final_message: "Platform baseline cloud-init completed after $UPTIME seconds"
