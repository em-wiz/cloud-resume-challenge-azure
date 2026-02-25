terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-devopscore-dev-weu"
    storage_account_name = "stdevopscoredevweu01"
    container_name       = "tfstate"
    key                  = "cloud-resume.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "crc" {
  location = "westeurope"
  name     = "rg-cloud-resume-azure"
  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "crc" {
  name                          = "db-cloudresume-dev-weu"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.crc.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  free_tier_enabled             = true
  automatic_failover_enabled    = true
  public_network_access_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    failover_priority = 0
    location          = "westeurope"
  }

  backup {
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Local"
    type                = "Periodic"
  }

  tags = {
    Environment       = "Dev"
    Owner             = "Wisdom Emmanuel"
    Platform          = "Azure"
    Project           = "CloudResumeChallenge"
    defaultExperience = "Core (SQL)"
  }
}

# Storage Account
resource "azurerm_storage_account" "crc" {
  name                     = "rgcloudresumeazureb08a"
  resource_group_name      = azurerm_resource_group.crc.name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  share_properties {
    retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}

# Service Plan
resource "azurerm_service_plan" "crc" {
  name                = "ASP-rgcloudresumeazure-9e34"
  resource_group_name = azurerm_resource_group.crc.name
  location            = "westeurope"
  os_type             = "Linux"
  sku_name            = "FC1" # Flex 
  
  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}

resource "azurerm_storage_container" "app_package" {
  name                  = "app-package-func-cloudresumeapi-dev-weu-cf3ef6b"
  storage_account_name  = azurerm_storage_account.crc.name
  container_access_type = "private"
}

# Linux Function App
resource "azurerm_function_app_flex_consumption" "crc" {
  name                = "func-cloudresumeapi-dev-weu"
  resource_group_name = azurerm_resource_group.crc.name
  location            = "westeurope"
  service_plan_id     = azurerm_service_plan.crc.id

  instance_memory_in_mb = 512

  runtime_name    = "python"
  runtime_version = "3.10"

  # Storage settings
  storage_container_type      = "blobContainer"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_container_endpoint  = "${azurerm_storage_account.crc.primary_blob_endpoint}app-package-func-cloudresumeapi-dev-weu-cf3ef6b"
  storage_access_key          = azurerm_storage_account.crc.primary_access_key

  https_only = true

  site_config {
    cors {
      allowed_origins = ["https://portal.azure.com", "https://wisdomresume.site", "https://www.wisdomresume.site"]
    }
  }

  app_settings = {
    COSMOS_CONTAINER         = "counter"
    COSMOS_DATABASE          = "VisitorsCount"
    COSMOS_ENDPOINT          = "https://db-cloudresume-dev-weu.documents.azure.com:443/"
    COSMOS_KEY               = azurerm_cosmosdb_account.crc.primary_key
  }

  tags = {
    Environment = "Dev"
    Owner       = "Wisdom Emmanuel"
    Platform    = "Azure"
    Project     = "CloudResumeChallenge"
  }
}