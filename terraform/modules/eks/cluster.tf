resource "aws_cloudwatch_log_group" "this" {
  count             = length(var.cluster_enabled_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id
  tags              = var.tags
}

resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.cluster_enabled_log_types
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version

  vpc_config {
    security_group_ids      = distinct(compact(concat([aws_security_group.cluster.id], var.additional_sgs)))
    subnet_ids              = var.subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_security_group" "cluster" {
  name        = var.cluster_sg_name == "" ? "${var.env}-${var.cluster_name}-eks-cluster-sg" : var.cluster_sg_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = var.cluster_sg_name == "" ? "${var.env}-${var.cluster_name}-eks-cluster-sg" : var.cluster_sg_name
    },
  )
}

# resource "aws_security_group_rule" "cluster_egress_internet" {
#   description       = "Allow cluster egress access to the Internet."
#   protocol          = "-1"
#   security_group_id = aws_security_group.cluster.id
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 0
#   to_port           = 0
#   type              = "egress"
# }

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_https_metrics_server_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster metrics server."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 8443
  to_port                  = 8443
  type                     = "ingress"
}

resource "aws_iam_role" "cluster" {
  name_prefix           = var.cluster_role_name == "" ? var.env : null
  name = var.cluster_role_name != "" ? var.cluster_role_name : null
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "null_resource" "k8s_cni" {
  triggers = {
    cni_environment = jsonencode(var.cni_configuration)
  }
  provisioner "local-exec" {
    command = "echo '${local.cni_rendered}' | kubectl --server=${aws_eks_cluster.this.endpoint} --insecure-skip-tls-verify=true --token=${data.aws_eks_cluster_auth.this.token} --kubeconfig=/dev/null apply -f -"
  }
}