variable "snowflake_organization_name" {
  description = "Snowflake organization name (from https://app.snowflake.com/<org>/<account>/...)"
  type        = string
  default     = "SVGSKZY"
}

variable "snowflake_account_name" {
  description = "Snowflake account name (from https://app.snowflake.com/<org>/<account>/...)"
  type        = string
  default     = "BN20283"
}

variable "snowflake_user" {
  description = "Snowflake user Terraform authenticates as (created by .bootstrap/bootstrap.sql)"
  type        = string
  default     = "TERRAFORM_SVC"
}

variable "snowflake_private_key" {
  description = "PEM-encoded RSA private key (PKCS8, unencrypted) matching the public key registered on TERRAFORM_SVC"
  type        = string
  sensitive   = true
}

variable "domain_prefix" {
  description = "Prefix for all Snowflake object names created by this project. Must match the domain_prefix used in terraform-snowflake-rbac, since that project grants USAGE on the integration names derived from it here."
  type        = string
  default     = "DATALAKE"
}

# --- Azure integration (values from terraform-azure's outputs, same
# resource names as the snowflakeRG dedicated storage account/queue) ---

variable "azure_tenant_id" {
  description = "Azure AD tenant ID backing the storage/notification integrations"
  type        = string
  default     = "e51ffb8d-9846-4f8e-8e2f-a05bfe018165"
}

variable "azure_storage_account_name" {
  description = "Name of the dedicated Azure storage account for Snowflake (terraform-azure's snowflake_storage_account_name output)"
  type        = string
  default     = "snowflakestg343432"
}

variable "azure_stage_container_name" {
  description = "Container Snowflake reads via external stage (terraform-azure's snowflake_stage_container_name output)"
  type        = string
  default     = "snowflake-stage"
}

variable "azure_notification_queue_name" {
  description = "Queue Snowpipe listens on for auto-ingest (terraform-azure's snowflake_notification_queue_name output)"
  type        = string
  default     = "snowflake-notifications"
}
