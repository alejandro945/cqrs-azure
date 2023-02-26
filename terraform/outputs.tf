# Salida para obtener la URI de la write database
output "write_db_uri" {
  value = azurerm_sql_server.write.fully_qualified_domain_name
}

# Salida del id del la write cosmo db
output "write_db_id" {
  value = azurerm_sql_server.write.id
}

# Salida para obtener la URI de la read database
output "read_db_uri" {
  value = azurerm_sql_server.read.fully_qualified_domain_name
}

# Salida del id del la read cosmo db
output "read_db_id" {
  value = azurerm_sql_server.read.id
}

# Salida para obtener la URL de la función del componente de comando
output "command_url" {
  value = azurerm_function_app.command.default_hostname
}

# Salida para obtener la URL de la función del componente de consulta
output "query_url" {
  value = azurerm_function_app.query.default_hostname
}