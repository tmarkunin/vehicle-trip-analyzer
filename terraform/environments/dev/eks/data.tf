data "aws_ssm_parameter" "key" {
  name = format("%s-public-key", var.eks_cluster_name)
}

