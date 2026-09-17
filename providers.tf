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
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  role              = "TERRAFORM_ROLE"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key
}
