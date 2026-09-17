resource "snowflake_database" "this" {
  name    = "${var.domain_prefix}_DB"
  comment = "Primary database for the ${var.domain_prefix} domain"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.this.name
  name     = "RAW"
}

# --- Roles ---

resource "snowflake_account_role" "functional" {
  name    = "${var.domain_prefix}_FUNC_ROLE"
  comment = "Business/functional role: read access for analysts and BI tools"
}

resource "snowflake_account_role" "technical" {
  name    = "${var.domain_prefix}_TECH_ROLE"
  comment = "Technical/service role: read-write access for pipelines and ingestion"
}

# Hierarchy: both roll up to SYSADMIN so objects stay visible under the
# normal role tree instead of being orphaned under standalone roles.
resource "snowflake_grant_account_role" "functional_to_sysadmin" {
  role_name        = snowflake_account_role.functional.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "technical_to_sysadmin" {
  role_name        = snowflake_account_role.technical.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_privileges_to_account_role" "functional_db_usage" {
  account_role_name = snowflake_account_role.functional.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "functional_schema_usage" {
  account_role_name = snowflake_account_role.functional.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "functional_select" {
  account_role_name = snowflake_account_role.functional.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "functional_select_future" {
  account_role_name = snowflake_account_role.functional.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "technical_db_usage" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "technical_schema_all" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE FILE FORMAT", "CREATE PIPE"]
  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "technical_dml" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "technical_dml_future" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

# --- Warehouse ---

resource "snowflake_warehouse" "this" {
  name                = "${var.domain_prefix}_WH"
  warehouse_size      = var.warehouse_size
  auto_suspend        = var.warehouse_auto_suspend_seconds
  auto_resume         = true
  initially_suspended = true
  comment             = "Main compute warehouse for the ${var.domain_prefix} domain"
}

resource "snowflake_grant_privileges_to_account_role" "functional_warehouse_usage" {
  account_role_name = snowflake_account_role.functional.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "technical_warehouse_usage" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

# --- Service account ---
# Used by pipelines/BI tools to connect (key-pair auth), not by Terraform
# itself (that's TERRAFORM_SVC, created by .bootstrap/bootstrap.sql).

resource "snowflake_user" "service_account" {
  name              = "${var.domain_prefix}_SVC_USER"
  rsa_public_key    = var.service_account_public_key
  default_role      = snowflake_account_role.technical.name
  default_warehouse = snowflake_warehouse.this.name
  comment           = "Service account for pipelines/BI tools (key-pair auth)"
}

resource "snowflake_grant_account_role" "technical_to_service_account" {
  role_name = snowflake_account_role.technical.name
  user_name = snowflake_user.service_account.name
}

# --- Azure integrations ---

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

resource "snowflake_grant_privileges_to_account_role" "technical_integration_usage" {
  account_role_name = snowflake_account_role.technical.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "INTEGRATION"
    object_name = snowflake_storage_integration.azure.name
  }
}
