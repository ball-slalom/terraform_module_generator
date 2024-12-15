# Azure Function App and API Management Module

This Terraform module creates an Azure Function App, API Management service, and associated resources such as a storage account and storage container. It is designed to be reusable and easy to configure with default values for most settings.

## Resources Created

- Azure Resource Group
- Azure Storage Account
- Azure Storage Container
- Azure Function App Service Plan
- Azure Function App
- Azure API Management Service
- Azure API Management API

## Usage

### Example 1: Using Default Values

This example demonstrates how to use the module with default values for optional variables.

```hcl
module "azure_function_app_api_management" {
  source = "./path-to-module"

  resource_group_name    = "example-rg"
  storage_account_name   = "examplestoracc"
  storage_container_name = "examplecontainer"
  function_app_name      = "examplefuncapp"
  api_management_name    = "exampleapimgmt"
  publisher_name         = "Example Publisher"
  publisher_email        = "publisher@example.com"
  api_name               = "exampleapi"
  api_display_name       = "Example API"
  api_path               = "example"
}
```

### Example 2: Using All Inputs

This example demonstrates how to use the module with all available inputs specified.

```hcl
module "azure_function_app_api_management" {
  source = "./path-to-module"

  resource_group_name    = "custom-rg"
  location               = "West Europe"
  storage_account_name   = "customstoracc"
  storage_container_name = "customcontainer"
  function_app_name      = "customfuncapp"
  api_management_name    = "customapimgmt"
  publisher_name         = "Custom Publisher"
  publisher_email        = "custompublisher@example.com"
  api_name               = "customapi"
  api_display_name       = "Custom API"
  api_path               = "custom"
}
```

## Inputs

| Name                   | Description                                                       | Type   | Default   | Required |
|------------------------|-------------------------------------------------------------------|--------|-----------|----------|
| resource_group_name    | The name of the resource group in which to create the resources.  | string | n/a       | yes      |
| location               | The Azure region where the resources will be created.             | string | "East US" | no       |
| storage_account_name   | The name of the storage account.                                  | string | n/a       | yes      |
| storage_container_name | The name of the storage container.                                | string | n/a       | yes      |
| function_app_name      | The name of the function app.                                     | string | n/a       | yes      |
| api_management_name    | The name of the API Management service.                           | string | n/a       | yes      |
| publisher_name         | The name of the publisher for the API Management service.         | string | n/a       | yes      |
| publisher_email        | The email of the publisher for the API Management service.        | string | n/a       | yes      |
| api_name               | The name of the API in the API Management service.                | string | n/a       | yes      |
| api_display_name       | The display name of the API in the API Management service.        | string | n/a       | yes      |
| api_path               | The path of the API in the API Management service.                | string | n/a       | yes      |

## Outputs

| Name                  | Description                                 |
|-----------------------|---------------------------------------------|
| function_app_id       | The ID of the Function App.                 |
| api_management_id     | The ID of the API Management service.       |
| storage_account_id    | The ID of the Storage Account.              |
| storage_container_id  | The ID of the Storage Container.            |

## Recommendations

- Ensure that the storage account name is globally unique.
- The function app and API management service names should also be unique within your Azure subscription.
- Consider using Azure Key Vault to manage sensitive information like storage account keys.