# terraform {
#   required_providers {
#     snowflake = {
#       source  = "Snowflake-Labs/snowflake"
#       version = "0.69.0"
#     }
#   }
# }

provider "snowflake" {
  role     = "ORGADMIN"
  alias    = "orgadmin"
  username = var.username
  password = var.password
  account  = var.account
}

resource "snowflake_account" "ac1" {
    depends_on = [ azurerm_linux_virtual_machine.Azure_snowflake ]
  provider             = snowflake.orgadmin
  name                 = var.name
  admin_name           = var.admin_username
  admin_password       = var.admin_password
  email                = var.email
  first_name           = var.first_name
  last_name            = var.last_name
  must_change_password = var.must_change_password
  edition              = var.edition
  comment              = var.comment
  region               = var.region
  
}

