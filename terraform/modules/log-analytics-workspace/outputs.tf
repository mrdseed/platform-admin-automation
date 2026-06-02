output "id" {
  description = "Log Analytics workspace ARM ID — use for diagnostic settings"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Workspace GUID — pass to linux-vm module as log_analytics_workspace_guid"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key for legacy agents (prefer Azure Monitor Agent)"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
