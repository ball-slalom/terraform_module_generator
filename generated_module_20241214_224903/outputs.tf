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