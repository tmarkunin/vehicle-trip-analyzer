locals {
  custom_eks_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
  mandatory_tags = {
    "Environment"     = module.eks_naming.environment
    "InspectorTarget" = module.eks_naming.inspector_target
    "Owner"           = module.eks_naming.owner
    "Product"         = module.eks_naming.product_name
  }
  eks_tags_result = merge(module.eks_naming.tags, local.custom_eks_tags, local.mandatory_tags)
}

module "eks" {
  source          = "./modules/eks"
  env             = var.env
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc.vpc_id
  cluster_name    = var.eks_cluster_name
  subnets         = data.terraform_remote_state.vpc.outputs.vpc.private_eks_subnets
  region          = var.region
  tags            = local.eks_tags_result
  cluster_version = var.cluster_version

  worker_groups = [
    {
      name                 = var.eks_cluster_name
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.asg_desired_capacity
      asg_max_size         = var.asg_max_size
      asg_min_size         = var.asg_min_size
      subnets              = data.terraform_remote_state.vpc.outputs.vpc.private_eks_subnets
      key_name             = aws_key_pair.key.key_name
      kubelet_extra_args   = "--node-labels=group=app"
      autoscaling          = "enabled"
      root_volume_size     = var.worker_root_volume_size
      tags                 = module.eks_naming.tags_as_list_of_map
    }
  ]
  map_roles = var.map_roles
}
