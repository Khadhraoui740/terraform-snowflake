output "storage_integration_name" {
  value = snowflake_storage_integration.azure.name
}

output "notification_integration_name" {
  value = snowflake_notification_integration.azure.name
}
