# --- Azure integrations ---
# Database, roles, warehouse and service account live in the
# terraform-snowflake-rbac project instead — this project only owns the
# account-level integration objects, which need CREATE INTEGRATION
# (ACCOUNTADMIN-level bootstrap) and have their own lifecycle tied to the
# Azure storage account.

resource "snowflake_storage_integration" "azure" {
  name                      = "${var.domain_prefix}_AZURE_STORAGE_INT"
  storage_provider          = "AZURE"
  enabled                   = true
  azure_tenant_id           = var.azure_tenant_id
  storage_allowed_locations = ["azure://${var.azure_storage_account_name}.blob.core.windows.net/${var.azure_stage_container_name}/"]
  comment                   = "External stage access to the dedicated Snowflake storage account in Azure"
}

resource "snowflake_notification_integration" "azure" {
  name                            = "${var.domain_prefix}_AZURE_NOTIFICATION_INT"
  enabled                         = true
  notification_provider           = "AZURE_STORAGE_QUEUE"
  azure_storage_queue_primary_uri = "https://${var.azure_storage_account_name}.queue.core.windows.net/${var.azure_notification_queue_name}"
  azure_tenant_id                 = var.azure_tenant_id
  comment                         = "Snowpipe auto-ingest notifications from Azure Event Grid via Storage Queue"
}

# Granting USAGE on this integration to the technical role happens in
# terraform-snowflake-rbac (object_name is the deterministic
# "${domain_prefix}_AZURE_STORAGE_INT" derived above, so no cross-project
# output wiring is needed).
