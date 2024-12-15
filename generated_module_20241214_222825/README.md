# Terraform AWS EKS Module

This Terraform module creates and manages Amazon Elastic Kubernetes Service (EKS) clusters and their associated resources, including node groups, IAM roles, and security groups. It is designed to be flexible and easy to use, providing sensible defaults while allowing customization for specific needs.

## Usage

### Example 1: Using Default Values

This example demonstrates how to use the module with default values for most variables. You only need to specify the `vpc_id` and `subnet_ids`.

```hcl
module "eks" {
  source = "./path-to-your-module"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
}
```

### Example 2: Using All Inputs

This example shows how to use the module with all available inputs, providing full customization.

```hcl
module "eks" {
  source = "./path-to-your-module"

  region                  = "us-east-1"
  cluster_names           = {
    dev  = "custom-dev-cluster"
    test = "custom-test-cluster"
    stg  = "custom-stg-cluster"
    prod = "custom-prod-cluster"
  }
  node_instance_type      = "m5.large"
  desired_capacity        = 3
  max_size                = 5
  min_size                = 2
  vpc_id                  = "vpc-12345678"
  subnet_ids              = ["subnet-12345678", "subnet-87654321"]
  security_group_ids      = ["sg-12345678", "sg-87654321"]
  custom_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

## Inputs

- **region**: The AWS region to deploy the EKS clusters. Default is `us-west-2`.
- **cluster_names**: A map of environment names to EKS cluster names. Default is `{ dev = "dev-cluster", test = "test-cluster", stg = "stg-cluster", prod = "prod-cluster" }`.
- **node_instance_type**: The EC2 instance type for the EKS worker nodes. Default is `t3.medium`.
- **desired_capacity**: The desired number of worker nodes in the EKS cluster. Default is `2`.
- **max_size**: The maximum number of worker nodes in the EKS cluster. Default is `3`.
- **min_size**: The minimum number of worker nodes in the EKS cluster. Default is `1`.
- **vpc_id**: The VPC ID where the EKS cluster will be deployed. (Required)
- **subnet_ids**: A list of subnet IDs for the EKS cluster. (Required)
- **security_group_ids**: A list of additional security group IDs to attach to the EKS cluster. Default is `[]`.
- **custom_security_group_rules**: A list of custom security group rules for the EKS cluster. Each rule is an object with `type`, `from_port`, `to_port`, `protocol`, and `cidr_blocks`. Default is `[]`.

## Outputs

- **eks_cluster_names**: Names of the EKS clusters.
- **eks_cluster_endpoints**: Endpoints of the EKS clusters.
- **eks_cluster_arns**: ARNs of the EKS clusters.
- **node_group_names**: Names of the EKS node groups.

## Recommendations

- Ensure that the VPC and subnets are properly configured for EKS.
- Consider using AWS Secrets Manager or Parameter Store for sensitive data.
- Regularly review IAM policies and roles for least privilege access.