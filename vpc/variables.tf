variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "mlops-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets (EKS nodes)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets (NAT, load balancers)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster, used for kubernetes.io subnet tags"
  type        = string
  default     = "mlops-eks"
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
