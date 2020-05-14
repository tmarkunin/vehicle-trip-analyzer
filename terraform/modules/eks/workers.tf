# Worker Groups using Launch Configurations

resource "aws_autoscaling_group" "workers" {
  count = local.worker_group_count
  name_prefix = join(
    "-",
    compact(
      [
        aws_eks_cluster.this.name,
        lookup(var.worker_groups[count.index], "name", count.index)
      ]
    )
  )
  desired_capacity     = lookup(var.worker_groups[count.index], "asg_desired_capacity")
  max_size             = lookup(var.worker_groups[count.index], "asg_max_size")
  min_size             = lookup(var.worker_groups[count.index], "asg_min_size")
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier  = lookup(var.worker_groups[count.index], "subnets")
  enabled_metrics      = lookup(var.worker_groups[count.index], "enabled_metrics", null)

  tags = concat(
    lookup(var.worker_groups[count.index], "tags", []),
    lookup(var.worker_groups[count.index], "autoscaling", "disabled") == "enabled" ?
    [
      {
        key                 = "k8s.io/cluster-autoscaler/enabled"
        value               = "true"
        propagate_at_launch = "true"
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}"
        value               = "true"
        propagate_at_launch = "true"
      }
    ] :
  [])

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_configuration" "workers" {
  count                = local.worker_group_count
  name_prefix          = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  security_groups      = flatten([aws_security_group.workers.id, lookup(var.worker_groups[count.index], "additional_security_group_ids", [])])
  iam_instance_profile = aws_iam_instance_profile.workers.id
  image_id             = lookup(var.worker_groups[count.index], "ami_id", data.aws_ami.eks_worker.id)
  instance_type        = lookup(var.worker_groups[count.index], "instance_type")
  key_name             = lookup(var.worker_groups[count.index], "key_name", "")
  user_data_base64     = base64encode(data.template_file.userdata.*.rendered[count.index])
  ebs_optimized        = lookup(var.worker_groups[count.index], "ebs_optimized", false)
  enable_monitoring    = lookup(var.worker_groups[count.index], "enable_monitoring", false)
  root_block_device {
    volume_size           = lookup(var.worker_groups[count.index], "root_volume_size", 10)
    volume_type           = lookup(var.worker_groups[count.index], "root_volume_type", "gp2")
    iops                  = lookup(var.worker_groups[count.index], "root_iops", 0)
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workers" {
  name        = var.worker_sg_name == "" ? "${var.env}-${aws_eks_cluster.this.name}-eks-worker-sg" : var.worker_sg_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                               = var.worker_sg_name == "" ? "${var.env}-${aws_eks_cluster.this.name}-eks-worker-sg" : var.worker_sg_name
      "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description       = "Allow node to communicate with each other."
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  self              = true
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 10250
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_metrics_ingress_cluster_https" {
  description              = "Allow metrics running extension API servers on port 8443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 8443
  to_port                  = 8443
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  name                  = var.worker_role_name == "" ? "${var.env}-${var.cluster_name}-worker-role" : var.worker_role_name
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${var.env}-${var.cluster_name}"
  role        = aws_iam_role.workers.name
  path        = var.iam_path
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = length(var.workers_additional_policies)
  role       = aws_iam_role.workers.name
  policy_arn = var.workers_additional_policies[count.index]
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    key                 = keys(var.tags)[count.index]
    value               = values(var.tags)[count.index]
    propagate_at_launch = "true"
  }
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  policy_arn = aws_iam_policy.alb_ingress.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
  path        = var.iam_path
}

resource "aws_iam_policy" "alb_ingress" {
  name_prefix = "eks-alb-ingress-${aws_eks_cluster.this.name}"
  description = "EKS worker node alb ingress controller policy for cluster ${aws_eks_cluster.this.name}"
  policy      = data.aws_iam_policy_document.alb_ingress.json
  path        = var.iam_path
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["shared", "owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

# https://kubernetes-sigs.github.io/aws-alb-ingress-controller/examples/iam-policy.json
data "aws_iam_policy_document" "alb_ingress" {
  statement {
    sid    = "eksAlbIngressACM"
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressEC2"
    effect = "Allow"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressELB"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressIAM"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressCognito"
    effect = "Allow"

    actions = [
      "cognito-idp:DescribeUserPoolClient"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressWafRegional"
    effect = "Allow"

    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressTag"
    effect = "Allow"

    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "eksAlbIngressWaf"
    effect = "Allow"

    actions = [
      "waf:GetWebACL"
    ]
    resources = ["*"]
  }
}
