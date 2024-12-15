# Providers
provider "aws" {
  region = var.region
}

# Variables
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

# Resources
resource "aws_eks_cluster" "eks" {
  for_each = var.cluster_names

  name     = each.value
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = concat([aws_security_group.eks_sg.id], var.security_group_ids)
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

resource "aws_eks_node_group" "node_group" {
  for_each = var.cluster_names

  cluster_name    = aws_eks_cluster.eks[each.key].name
  node_group_name = "${each.key}-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.node_instance_type]
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role" "node_role" {
  name = "eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCNIPolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_security_group" "eks_sg" {
  name   = "eks-cluster-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.custom_security_group_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# Data Sources
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Outputs
output "eks_cluster_names" {
  description = "Names of the EKS clusters."
  value       = aws_eks_cluster.eks[*].name
}

output "eks_cluster_endpoints" {
  description = "Endpoints of the EKS clusters."
  value       = { for k, v in aws_eks_cluster.eks : k => v.endpoint }
}

output "eks_cluster_arns" {
  description = "ARNs of the EKS clusters."
  value       = { for k, v in aws_eks_cluster.eks : k => v.arn }
}

output "node_group_names" {
  description = "Names of the EKS node groups."
  value       = aws_eks_node_group.node_group[*].node_group_name
}

# Recommendations
# - Ensure that the VPC and subnets are properly configured for EKS.
# - Consider using AWS Secrets Manager or Parameter Store for sensitive data.
# - Regularly review IAM policies and roles for least privilege access.