# Terraform AWS Aurora Module

## Overview

This Terraform module provisions an Amazon Aurora MySQL cluster along with associated resources such as RDS instances, a DB subnet group, Secrets Manager secrets for custom users, and an RDS proxy. It is designed to be flexible and easy to use, with sensible defaults for most configurations.

## Resources Created

- AWS RDS Cluster
- AWS RDS Cluster Instances
- AWS DB Subnet Group
- AWS Secrets Manager Secrets for custom users
- AWS RDS Proxy
- AWS IAM Role and Policy for RDS Proxy

## Usage

### Example 1: Using Default Values

This example demonstrates how to use the module with default values for most variables.

```hcl
module "aurora" {
  source = "./path-to-your-module"

  master_password = "your-secure-password"
  subnet_ids      = ["subnet-abc123", "subnet-def456"]
}
```

### Example 2: Using All Inputs

This example demonstrates how to use the module with all available inputs specified.

```hcl
module "aurora" {
  source = "./path-to-your-module"

  region                = "us-east-1"
  cluster_identifier    = "custom-aurora-cluster"
  database_name         = "customdatabase"
  master_username       = "customadmin"
  master_password       = "your-secure-password"
  instance_class        = "db.r5.xlarge"
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  subnet_ids            = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
  usernames             = ["customuser1", "customuser2", "customuser3"]
}
```

## Inputs

| Name                   | Description                                                   | Type         | Default            | Required |
|------------------------|---------------------------------------------------------------|--------------|--------------------|----------|
| region                 | The AWS region to deploy resources in.                        | string       | "us-west-2"        | no       |
| cluster_identifier     | The identifier for the Aurora cluster.                        | string       | "my-aurora-cluster"| no       |
| database_name          | The name of the default database to create in the cluster.    | string       | "mydatabase"       | no       |
| master_username        | The master username for the Aurora cluster.                   | string       | "admin"            | no       |
| master_password        | The master password for the Aurora cluster.                   | string       | n/a                | yes      |
| instance_class         | The instance class for the Aurora instances.                  | string       | "db.r5.large"      | no       |
| vpc_security_group_ids | List of VPC security groups to associate with the cluster.    | list(string) | []                 | no       |
| subnet_ids             | List of subnet IDs for the Aurora cluster.                    | list(string) | n/a                | yes      |
| usernames              | List of custom usernames to create in the Aurora cluster.     | list(string) | ["user1", "user2"] | no       |

## Outputs

| Name                   | Description                                      |
|------------------------|--------------------------------------------------|
| aurora_cluster_endpoint| The endpoint of the Aurora cluster.              |
| aurora_proxy_endpoint  | The endpoint of the RDS proxy.                   |
| user_secrets           | The ARNs of the Secrets Manager secrets for custom users. |

## Notes

- Ensure that the `master_password` is a secure string and meets AWS RDS password requirements.
- The `subnet_ids` variable must be provided and should include subnets in the same VPC.
- The IAM role and policy created for the RDS proxy are configured to allow access to Secrets Manager for the custom users.