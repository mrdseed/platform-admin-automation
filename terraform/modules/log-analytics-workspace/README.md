# Log Analytics Workspace Module

Central observability workspace for diagnostic settings and Azure Monitor Agent.

## Usage

```hcl
module "log_analytics" {
  source = "../../modules/log-analytics-workspace"

  name                = "law-platform-prod-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "prod"
  retention_in_days   = 90
  tags                = module.resource_group.tags
}

module "linux_vm" {
  # ...
  log_analytics_workspace_guid = module.log_analytics.workspace_id
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | ARM ID — pass to diagnostic settings |
| workspace_id | GUID — pass to linux-vm AMA extension |
| name | Workspace name |

## Required RBAC

`PlatformDeploy-Monitoring`
