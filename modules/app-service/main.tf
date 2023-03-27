terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.24"
    }
  }
}

resource "azurecaf_name" "app_service_plan" {
  name          = var.application_name
  resource_type = "azurerm_app_service_plan"
  suffixes      = [var.environment]
}

# This creates the plan that the service use
resource "azurerm_service_plan" "application" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = var.resource_group
  location            = var.location

  sku_name = "B1"
  os_type  = "Linux"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "app_identity" {
  name          = var.application_name
  resource_type = "azurerm_user_assigned_identity"
  suffixes      = [var.environment, "app"]
}

resource "azurerm_user_assigned_identity" "app_identity" {
  resource_group_name = var.resource_group
  name                = azurecaf_name.app_identity.result
  location            = var.location
}

resource "azurecaf_name" "app_service" {
  name          = var.application_name
  resource_type = "azurerm_app_service"
  suffixes      = [var.environment]
}

locals {
  database_connection_string= "Server=tcp:${var.database_server_fqdn};Database=${var.database_name};Authentication=Active Directory Default;TrustServerCertificate=True;User ID=${azurerm_user_assigned_identity.app_identity.client_id};"
}

# This creates the service definition
resource "azurerm_linux_web_app" "application" {
  name                = azurecaf_name.app_service.result
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.application.id
  https_only          = true
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    health_check_path = "/healthz"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"

    # These are app specific environment variables

    "AZURE_MSSQL_CONNECTIONSTRING" = local.database_connection_string
  }
}
