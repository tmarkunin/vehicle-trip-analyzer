resource "aws_key_pair" "key" {
  key_name   = format("%s-public-key", var.eks_cluster_name)
  public_key = data.aws_ssm_parameter.key.value
}