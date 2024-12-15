# Variables
variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "cluster_identifier" {
  description = "The identifier for the Aurora cluster."
  type        = string
  default     = "my-aurora-cluster"
}

variable "database_name" {
  description = "The name of the default database to create in the cluster."
  type        = string
  default     = "mydatabase"
}

variable "master_username" {
  description = "The master username for the Aurora cluster."
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "The master password for the Aurora cluster."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "The instance class for the Aurora instances."
  type        = string
  default     = "db.r5.large"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the cluster."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora cluster."
  type        = list(string)
}

variable "usernames" {
  description = "List of custom usernames to create in the Aurora cluster."
  type        = list(string)
  default     = ["user1", "user2"]
}