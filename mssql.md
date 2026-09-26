terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "08b7b8d4-af42-4972-9517-11ea256ea068"
}

resource "azurerm_resource_group" "rg" {
  name     = "myRG"
  location = "Canada Central"
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "mysqlserver98600"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
}

resource "azurerm_mssql_database" "sql_database" {
  name         = "example-db"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "prod"
  }
}
