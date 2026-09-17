terraform {
  required_version = ">= 1.5"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.95"
    }
  }

  # Reuses the same state storage as terraform-azure (different key), so no
  # new backend/RBAC bootstrap was needed for this project.
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatedbriksd248f2"
    container_name       = "tfstate"
    key                  = "terraform-snowflake.tfstate"
    use_azuread_auth     = true
  }
}

provider "snowflake" {
  account       = var.snowflake_account
  user          = var.snowflake_user
  role          = "TERRAFORM_ROLE"
  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}
