output "database_name" {
  value = snowflake_database.this.name
}

output "functional_role" {
  value = snowflake_account_role.functional.name
}

output "technical_role" {
  value = snowflake_account_role.technical.name
}

output "warehouse_name" {
  value = snowflake_warehouse.this.name
}

output "service_account_user" {
  value = snowflake_user.service_account.name
}

output "storage_integration_name" {
  value = snowflake_storage_integration.azure.name
}

output "notification_integration_name" {
  value = snowflake_notification_integration.azure.name
}
