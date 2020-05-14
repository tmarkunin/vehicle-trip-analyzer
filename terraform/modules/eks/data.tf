data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-${var.worker_ami_name_filter}"]
  }

  most_recent = true

  # Owner ID of AWS EKS team
  owners = ["602401143452"]
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "userdata" {
  count    = local.worker_group_count
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.this.name
    endpoint             = aws_eks_cluster.this.endpoint
    cluster_auth_base64  = aws_eks_cluster.this.certificate_authority[0].data
    pre_userdata         = lookup(var.worker_groups[count.index], "pre_userdata", "")
    additional_userdata  = lookup(var.worker_groups[count.index], "additional_userdata", "")
    bootstrap_extra_args = lookup(var.worker_groups[count.index], "bootstrap_extra_args", "")
    kubelet_extra_args   = lookup(var.worker_groups[count.index], "kubelet_extra_args", "")
  }
}


data "template_file" "worker_role_arns" {
  count    = local.worker_group_count
  template = file("${path.module}/templates/worker-role.tpl")

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(coalescelist(aws_iam_instance_profile.workers.*.role), count.index, )}"
  }
}