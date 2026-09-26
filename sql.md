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

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount98600"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
