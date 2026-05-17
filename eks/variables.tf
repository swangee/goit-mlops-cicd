variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "mlops-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster is created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types for the node groups"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public cluster API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
