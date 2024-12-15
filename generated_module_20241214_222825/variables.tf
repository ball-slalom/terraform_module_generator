variable "region" {
  description = "The AWS region to deploy the EKS clusters."
  type        = string
  default     = "us-west-2"
}

variable "cluster_names" {
  description = "Names of the EKS clusters for each environment."
  type        = map(string)
  default = {
    dev  = "dev-cluster"
    test = "test-cluster"
    stg  = "stg-cluster"
    prod = "prod-cluster"
  }
}

variable "node_instance_type" {
  description = "Instance type for the EKS worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes in the EKS cluster."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes in the EKS cluster."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes in the EKS cluster."
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets IDs for the EKS cluster."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "custom_security_group_rules" {
  description = "Custom security group rules for the EKS cluster."
  type        = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}