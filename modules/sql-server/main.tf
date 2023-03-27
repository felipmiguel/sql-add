terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.24"
    }
  }
}

resource "azurecaf_name" "mssql_server" {
  name          = var.application_name
  resource_type = "azurerm_mssql_server"
  suffixes      = [var.environment]
}

# resource "random_password" "password" {
#   length           = 32
#   special          = true
#   override_special = "_%@"
# }

data "azuread_user" "aad_admin" {
  user_principal_name = var.aad_admin
}

data "azurerm_client_config" "current" {}

resource "azurerm_mssql_server" "database" {
  name                = azurecaf_name.mssql_server.result
  resource_group_name = var.resource_group
  location            = var.location
  version             = "12.0"

  azuread_administrator {
    azuread_authentication_only = true
    login_username              = data.azuread_user.aad_admin.user_principal_name
    object_id                   = data.azuread_user.aad_admin.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
  }

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "mssql_database" {
  name          = var.application_name
  resource_type = "azurerm_mssql_database"
  suffixes      = [var.environment]
}

resource "azurerm_mssql_database" "database" {
  name      = azurecaf_name.mssql_database.result
  server_id = azurerm_mssql_server.database.id
  collation = "SQL_Latin1_General_CP1_CI_AS"

  sku_name = "GP_Gen5_2"
}

resource "azurecaf_name" "sql_firewall_rule" {
  name          = var.application_name
  resource_type = "azurerm_sql_firewall_rule"
  suffixes      = [var.environment]
}

# This rule is to enable the 'Allow access to Azure services' checkbox
resource "azurerm_mssql_firewall_rule" "database" {
  name             = azurecaf_name.sql_firewall_rule.result
  server_id        = azurerm_mssql_server.database.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
