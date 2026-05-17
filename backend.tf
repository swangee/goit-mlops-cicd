terraform {
  backend "s3" {
    bucket  = "mlops-tfstate-eugenel"
    key     = "eks-vpc-cluster/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}
