# Providers
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

# Storage Container
resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Function App Service Plan
resource "azurerm_app_service_plan" "plan" {
  name                = "${var.function_app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Function App
resource "azurerm_function_app" "function" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  os_type                    = "linux"  # Corrected to lowercase
  version                    = "~4"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}

# API Management Service
resource "azurerm_api_management" "api_management" {
  name                = var.api_management_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0"

  identity {
    type = "SystemAssigned"
  }
}

# API Management API
resource "azurerm_api_management_api" "api" {
  name                = var.api_name
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.api_management.name
  revision            = "1"
  display_name        = var.api_display_name
  path                = var.api_path
  protocols           = ["https"]
}

# Variables
variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "storage_container_name" {
  description = "The name of the storage container."
  type        = string
}

variable "function_app_name" {
  description = "The name of the function app."
  type        = string
}

variable "api_management_name" {
  description = "The name of the API Management service."
  type        = string
}

variable "publisher_name" {
  description = "The name of the publisher for the API Management service."
  type        = string
}

variable "publisher_email" {
  description = "The email of the publisher for the API Management service."
  type        = string
}

variable "api_name" {
  description = "The name of the API in the API Management service."
  type        = string
}

variable "api_display_name" {
  description = "The display name of the API in the API Management service."
  type        = string
}

variable "api_path" {
  description = "The path of the API in the API Management service."
  type        = string
}

# Outputs
output "function_app_id" {
  description = "The ID of the Function App."
  value       = azurerm_function_app.function.id
}

output "api_management_id" {
  description = "The ID of the API Management service."
  value       = azurerm_api_management.api_management.id
}

output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.storage.id
}

output "storage_container_id" {
  description = "The ID of the Storage Container."
  value       = azurerm_storage_container.container.id
}

# Recommendations:
# - Ensure that the storage account name is globally unique.
# - The function app and API management service names should also be unique within your Azure subscription.
# - Consider using Azure Key Vault to manage sensitive information like storage account keys.