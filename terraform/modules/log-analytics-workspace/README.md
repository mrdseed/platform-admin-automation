# Log Analytics Workspace Module

Central observability workspace for diagnostic settings and Azure Monitor Agent.

## Usage

```hcl
module "log_analytics" {
  source = "../../modules/log-analytics-workspace"

  name                = "law-platform-dev-eus2-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = "dev"
  retention_in_days   = 30

  tags = local.platform_tags
}
```

Downstream modules consume `module.log_analytics.id` for diagnostic settings.

## Required RBAC

`PlatformDeploy-Monitoring` custom role.
