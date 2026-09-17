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
  description = "Prefix for all Snowflake object names created by this project"
  type        = string
  default     = "DATALAKE"
}

variable "warehouse_size" {
  description = "Warehouse size"
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_suspend_seconds" {
  description = "Seconds of inactivity before the warehouse auto-suspends"
  type        = number
  default     = 60
}

variable "service_account_public_key" {
  description = "RSA public key (base64 body only, no PEM headers) for the DATALAKE_SVC_USER service account. Not sensitive — the matching private key (.bootstrap/svc_rsa_key.p8, kept out of git) is what pipelines/BI tools authenticate with."
  type        = string
  default     = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0P+5v3ozX4PwvahgUK/MYNg6+qJEFDRGPXZFw3zVDGcgEx7nJ9dnoCwHXuTyenx4UMbLclgqhFxGFxcXy7iK35PL25fYA2QwZO2Vp1aLmbH9aS6cfTMdhZQMqOOHXJuEenqA/9AutD7Iao9kn3OdaBNHLX7fkw2Fm4YIV7UpqpY/qNb/zcM64ydZkXAm6I0eznRnEhTxcY47uQhTNuUrLDK+4T5ZXuInR8fofJrenIERwT3ifsY2X24/naDkAZIdQOn85CxNsurgJ5/iQ4sZEcT7pqpUatBY+bhg+V8QOO1ZNNiDR1G5UuqQZnlKFeNWEUXjTPIXQuQ9e/XRbkOWuQIDAQAB"
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
