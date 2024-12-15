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