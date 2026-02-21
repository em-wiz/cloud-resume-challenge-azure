terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Reference existing resource group
data "azurerm_resource_group" "crc" {
  name = "rg-cloud-resume-azure"
}

# Manages existing Cosmos DB with it's current settings
resource "azurerm_cosmosdb_account" "crc" {
  name                = "db-cloudresume-dev-weu"
  resource_group_name = "rg-cloud-resume-azure"
  location            = "westeurope"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = true
  automatic_failover_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "westeurope"
    failover_priority = 0
  }

}