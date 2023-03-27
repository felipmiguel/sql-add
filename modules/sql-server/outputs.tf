output "database_url" {
  value       = "${azurerm_mssql_server.database.name}.database.windows.net:1433;database=${azurerm_mssql_database.database.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  description = "The Azure SQL server URL."
}

output "database_server_fqdn" {
  value       = azurerm_mssql_server.database.fully_qualified_domain_name
  description = "The Azure SQL server FQDN."
}

output "database_name" {
  value       = azurerm_mssql_database.database.name
  description = "The Azure SQL database name."  
}