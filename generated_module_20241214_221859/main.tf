# Providers
provider "aws" {
  region = var.region
}

# Locals
locals {
  secret_names = [for username in var.usernames : "${var.cluster_identifier}-${username}-secret"]
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.cluster_identifier
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.10.1"
  skip_final_snapshot     = true
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = 2
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = "aurora-mysql"
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

# Secrets for Custom Users
resource "aws_secretsmanager_secret" "user_secrets" {
  count      = length(var.usernames)
  name       = local.secret_names[count.index]
  description = "Secret for ${var.usernames[count.index]} in Aurora cluster"
}

resource "aws_secretsmanager_secret_version" "user_secrets_version" {
  count      = length(var.usernames)
  secret_id  = aws_secretsmanager_secret.user_secrets[count.index].id
  secret_string = jsonencode({
    username = var.usernames[count.index]
    password = random_password.user_passwords[count.index].result
  })
}

# Random Passwords for Custom Users
resource "random_password" "user_passwords" {
  count           = length(var.usernames)
  length          = 16
  special         = true
  override_special = "_%@"
}

# RDS Proxy
resource "aws_db_proxy" "aurora_proxy" {
  name                   = "${var.cluster_identifier}-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.subnet_ids

  auth {
    username   = var.master_username
    secret_arn = aws_secretsmanager_secret.user_secrets[0].arn
    iam_auth   = "DISABLED"
  }
}

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "${var.cluster_identifier}-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for RDS Proxy
resource "aws_iam_policy" "rds_proxy_policy" {
  name        = "${var.cluster_identifier}-proxy-policy"
  description = "Policy for RDS Proxy to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.user_secrets[*].arn
      }
    ]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "rds_proxy_policy_attachment" {
  role       = aws_iam_role.rds_proxy_role.name
  policy_arn = aws_iam_policy.rds_proxy_policy.arn
}