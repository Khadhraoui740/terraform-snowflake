-- Run this once in a Snowflake worksheet as ACCOUNTADMIN, then never again.
-- It creates the service account Terraform uses to manage everything else
-- (database, roles, warehouse, integrations), authenticated with an RSA key
-- pair instead of a password so CI/CD never needs to know a password/MFA.

USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS TERRAFORM_ROLE
  COMMENT = 'Role used by Terraform CI/CD to manage Snowflake objects';

-- Object-creation privileges
GRANT CREATE DATABASE ON ACCOUNT TO ROLE TERRAFORM_ROLE;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE TERRAFORM_ROLE;
GRANT CREATE ROLE ON ACCOUNT TO ROLE TERRAFORM_ROLE;
GRANT CREATE USER ON ACCOUNT TO ROLE TERRAFORM_ROLE;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE TERRAFORM_ROLE;
-- Lets Terraform grant privileges on objects it doesn't itself own
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE TERRAFORM_ROLE;

-- Make it a child of SYSADMIN so objects it creates show up under the
-- normal role hierarchy instead of being orphaned under a standalone role.
GRANT ROLE TERRAFORM_ROLE TO ROLE SYSADMIN;

CREATE USER IF NOT EXISTS TERRAFORM_SVC
  RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxblgE5FVZmPOkXiWtxFjVexABU/7mzI313/3SagwHtnsny07a83d7hDyVWlFqhjHRnp4w5QAc2iuCxN25ygdxCAzO7TXWFk1PP8HWyO4nNAeaXLeD6drkR52r+n4Ub5A8t5L8jH83suLf/s9mlIQpfGVpnnJy3x679OdEjeorTEhcWyyEMxUzJP7z7llvC4CcRyzz/StSYseaFyUI+duM+pEDuTV3sxABAX5g8kBNEJIL0Mu3CaCfHanta8R55U+B7a5CRz/BTWSOGMP634QXpM9CAJIkbMQZRkhffSOyFyeq0J8fA06q2GNxv27dZtqiUFQL2njugUz4Ya6RKU9JwIDAQAB'
  DEFAULT_ROLE = TERRAFORM_ROLE
  DEFAULT_WAREHOUSE = 'COMPUTE_WH'
  COMMENT = 'Terraform CI/CD service account (key-pair auth only, no password)';

GRANT ROLE TERRAFORM_ROLE TO USER TERRAFORM_SVC;

-- Sanity check
DESC USER TERRAFORM_SVC;
SHOW GRANTS TO ROLE TERRAFORM_ROLE;
