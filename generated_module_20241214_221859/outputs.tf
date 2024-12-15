# Outputs
output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora cluster."
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_proxy_endpoint" {
  description = "The endpoint of the RDS proxy."
  value       = aws_db_proxy.aurora_proxy.endpoint
}

output "user_secrets" {
  description = "The ARNs of the Secrets Manager secrets for custom users."
  value       = aws_secretsmanager_secret.user_secrets[*].arn
}