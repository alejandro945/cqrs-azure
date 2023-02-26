# Configuración del proveedor de Azure
provider "azurerm" {
  features {}
}

# Recurso para el grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = "${var.project}-rg"
  location = var.location
}

# Cuentas de Storage en azure para las funciones serverless (such as the dashboard, logs)
resource "azurerm_storage_account" "command" {
  name                     = "${var.project}commandstorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "query" {
  name                     = "cqryquerystorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Componente de Azure Monitor que le permite recopilar métricas y registros de su aplicación de funciones.
resource "azurerm_application_insights" "command_insights" {
  name                = "${var.project}-command-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "Node.JS"
}

resource "azurerm_application_insights" "query_insights" {
  name                = "${var.project}-query-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "Node.JS"
}

# Recursos para el plan de servicio de aplicaciones (Serverless functions), defines the compute resources available to the FA
resource "azurerm_app_service_plan" "command" {
  name                = "${var.project}-command-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_app_service_plan" "query" {
  name                = "${var.project}-query-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Creación del server de la base de datos de lecturas
resource "azurerm_sql_server" "read" {
  name                         = "read-sql-server"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "H@Sh1CoR3!"
}

# Regla de firewall que permite todas las direcciones IP
resource "azurerm_sql_firewall_rule" "read" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.read.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Creación de la base de datos de lecturas
resource "azurerm_sql_database" "queries" {
  name                = "read-database"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  server_name         = azurerm_sql_server.read.name
}

# Creación del server de la base de datos de escrituras
resource "azurerm_sql_server" "write" {
  name                         = "write-sql-server"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "H@Sh1CoR3!"
}

# Regla de firewall que permite todas las direcciones IP
resource "azurerm_sql_firewall_rule" "write" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.write.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Creación de la base de datos de lecturas
resource "azurerm_sql_database" "people" {
  name                = "write-database"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.write.name
  location            = azurerm_resource_group.example.location
}

# Recursos para la función del componente de comando
resource "azurerm_function_app" "command" {
  name                       = "${var.project}-command-varela"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.command.id
  storage_account_name       = azurerm_storage_account.command.name
  storage_account_access_key = azurerm_storage_account.command.primary_access_key
  os_type                    = "linux"
  site_config {
    linux_fx_version          = "node|16"
    use_32_bit_worker_process = false
  }
  version = "~4"
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = ""
    FUNCTIONS_WORKER_RUNTIME       = "node"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.command_insights.instrumentation_key
    DB_SERVER                    = azurerm_sql_server.write.fully_qualified_domain_name
    DB_DATABASE                  = azurerm_sql_database.people.name
    DB_USER     = "sqladminuser"
    DB_PASSWORD = "H@Sh1CoR3!"
  }
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

# Recursos para la función del componente de consulta
resource "azurerm_function_app" "query" {
  name                       = "${var.project}-query-varela"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.query.id
  storage_account_name       = azurerm_storage_account.query.name
  storage_account_access_key = azurerm_storage_account.query.primary_access_key
  os_type                    = "linux"
  site_config {
    linux_fx_version          = "node|16"
    use_32_bit_worker_process = false
  }
  version = "~4"
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = ""
    FUNCTIONS_WORKER_RUNTIME       = "node"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.query_insights.instrumentation_key
    DB_SERVER                    = azurerm_sql_server.read.fully_qualified_domain_name
    DB_DATABASE                  = azurerm_sql_database.queries.name
    DB_USER     = "sqladminuser"
    DB_PASSWORD = "H@Sh1CoR3!"
  }
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

