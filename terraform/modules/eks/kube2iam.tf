resource "helm_release" "kube2iam" {
  count      = var.enable_kube2iam ? 1 : 0
  depends_on = [aws_autoscaling_group.workers]
  name       = "kube2iam"
  # namespace  = "kube-system"
  chart = "stable/kube2iam"

  values = var.path_to_values_kube2iam == null ? [] : [file(var.path_to_values_kube2iam)]
}
