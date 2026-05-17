output "aws_region" {
  description = "AWS region of the deployment"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "node_groups" {
  description = "Created node groups"
  value       = module.eks.eks_managed_node_groups
}

output "update_kubeconfig_command" {
  description = "Command to configure kubectl access to the cluster"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}
