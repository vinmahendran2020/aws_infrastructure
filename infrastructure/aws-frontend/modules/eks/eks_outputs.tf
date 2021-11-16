output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = module.eks_cluster.worker_security_group_id
}

output "cluster_id" {
  description = "Endpoint for EKS control plane."
  value       = module.eks_cluster.cluster_id
}