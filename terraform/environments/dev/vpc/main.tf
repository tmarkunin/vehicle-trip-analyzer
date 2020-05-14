module "tags" {
  source       = "./modules/naming"
  owner        = "devops"
  product_name = "devops"
  environment  = "dev"
}

module "vpc" {
  source         = "./modules/vpc"
  cidr           = var.cidr
  public_subnets = var.public_subnets
  private_subnets = {
    private = {
      subnets = var.private_subnets
      tags    = { "private_specific_tag" = "private_specific_value" }
    }
    eks = {
      subnets = var.eks_subnets
      tags    = { "eks_specific_tag" = "eks_specific_value" }
    }
  }
  name               = var.name
  single_nat_gateway = var.single_nat_gateway

  vpc_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "KubernetesCluster"      = var.eks_cluster_name
  }
}
