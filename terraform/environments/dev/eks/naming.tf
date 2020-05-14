module "eks_naming" {
  source              = "./modules/naming"
  environment         = var.env
  product_name        = var.product_name
  owner               = var.product_owner
  allowed_chars_regex = var.allowed_chars
  application_name    = "eks"
  customer            = "vehicle-trip-analyzer"
  security_domain     = "security_domain"
  instance_name       = "instance_name"

  tags = {
    Name                                            = var.eks_cluster_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
  additional_tags = {
    propagate_at_launch = "true"
  }
}
