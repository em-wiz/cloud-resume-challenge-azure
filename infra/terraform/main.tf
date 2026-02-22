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

# Manages existing Cosmos DB with it's current configs
resource "azurerm_cosmosdb_account" "crc" {
  name                = "db-cloudresume-dev-weu"
  resource_group_name = "rg-cloud-resume-azure"
  location            = "westeurope"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = true
  automatic_failover_enabled = true

  tags = {
    Environment          = "Dev"
    Owner                = "Wisdom Emmanuel"
    Platform             = "Azure"
    Project              = "CloudResumeChallenge"
    defaultExperience    = "Core (SQL)"
    "hidden-cosmos-mmspecial" = ""
    "hidden-workload-type"    = "Development/Testing"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "westeurope"
    failover_priority = 0
  }

}

# Manages existing Function App - App service plan with it's current configs
resource "azurerm_app_service_plan" "crc" {
  name                = "ASP-rgcloudresumeazure-9e34"
  location            = "westeurope"
  resource_group_name = "rg-cloud-resume-azure"

  kind = "functionapp"

  reserved = true          # indicates Linux
  sku {
    tier     = "FlexConsumption"
    size     = "FC1"
    capacity = 0
  }

  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}

# Manages existing Function App - Storage account with it's current configs
resource "azurerm_storage_account" "crc" {
  name                     = "rgcloudresumeazureb08a"
  resource_group_name      = "rg-cloud-resume-azure"
  location                 = "westeurope"

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled       = true
  cross_tenant_replication_enabled = false

  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}