# Diagrams

Architecture diagrams for the Azure platform landing zone. Source files use [Mermaid](https://mermaid.js.org/) syntax.

| Diagram | Source | Rendered | Description |
|---------|--------|----------|-------------|
| Hub-and-Spoke Topology | [hub-spoke-topology.mmd](hub-spoke-topology.mmd) | [hub-spoke-topology.svg](hub-spoke-topology.svg) | Hub VNet, spoke peerings, firewall egress |
| CI/CD Pipeline | [cicd-pipeline.mmd](cicd-pipeline.mmd) | — | GitHub Actions validation and deployment flow |
| Key Vault RBAC | [key-vault-rbac.mmd](key-vault-rbac.mmd) | — | RBAC roles, private endpoint, diagnostics |
| SFTP Platform | [sftp-platform.mmd](sftp-platform.mmd) | — | Partner connection sequence via Private Link |

## Rendering

- **GitHub**: Embed [hub-spoke-topology.svg](hub-spoke-topology.svg) in markdown for viewers without Mermaid support; Mermaid blocks in `docs/` render automatically where supported
- **VS Code**: Install a Mermaid preview extension and open `.mmd` files
- **CLI**: `npx @mermaid-js/mermaid-cli -i diagrams/hub-spoke-topology.mmd -o diagrams/hub-spoke-topology.svg`

## Maintenance

Update diagrams when architecture changes. Reference updates in PR description and `docs/architecture.md` revision history.
