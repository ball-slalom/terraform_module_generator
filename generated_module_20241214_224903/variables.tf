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