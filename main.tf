locals {
  common_tags = {
    Environment = "dev"
    Owner       = "mlops-course"
  }
}

module "vpc" {
  source = "./vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  cluster_name    = var.cluster_name

  tags = local.common_tags
}

module "eks" {
  source = "./eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  instance_types = var.instance_types

  tags = local.common_tags
}
