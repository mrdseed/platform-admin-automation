# Diagrams

Architecture diagrams for the Azure platform landing zone. Source files use [Mermaid](https://mermaid.js.org/) syntax.

| Diagram | File | Description |
|---------|------|-------------|
| Hub-and-Spoke Topology | [hub-spoke-topology.mmd](hub-spoke-topology.mmd) | Hub VNet, spoke peerings, firewall egress |
| CI/CD Pipeline | [cicd-pipeline.mmd](cicd-pipeline.mmd) | GitHub Actions validation and deployment flow |
| Key Vault RBAC | [key-vault-rbac.mmd](key-vault-rbac.mmd) | RBAC roles, private endpoint, diagnostics |
| SFTP Platform | [sftp-platform.mmd](sftp-platform.mmd) | Partner connection sequence via Private Link |

## Rendering

- **GitHub**: Mermaid blocks in markdown render automatically in `docs/` and `README.md`
- **VS Code**: Install a Mermaid preview extension and open `.mmd` files
- **CLI**: `npx @mermaid-js/mermaid-cli -i diagrams/hub-spoke-topology.mmd -o diagrams/hub-spoke-topology.svg`

## Maintenance

Update diagrams when architecture changes. Reference updates in PR description and `docs/architecture.md` revision history.
