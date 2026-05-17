module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_group_defaults = {
    instance_types = var.instance_types
    capacity_type  = "ON_DEMAND"
    disk_size      = 20
  }

  eks_managed_node_groups = {
    cpu = {
      name         = "cpu-ng"
      min_size     = 1
      max_size     = 3
      desired_size = 2

      labels = {
        workload = "cpu"
      }

      tags = {
        NodeGroup = "cpu"
      }
    }

    gpu = {
      name         = "gpu-ng"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        workload = "gpu"
      }

      taints = {
        gpu = {
          key    = "workload"
          value  = "gpu"
          effect = "NO_SCHEDULE"
        }
      }

      tags = {
        NodeGroup = "gpu"
      }
    }
  }

  tags = var.tags
}
