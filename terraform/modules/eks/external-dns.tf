resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  depends_on = [aws_autoscaling_group.workers]
  name       = "external-dns"
  # namespace  = "kube-system"
  chart = "stable/external-dns"

  values = var.path_to_values_external_dns == null ? [] : [file(var.path_to_values_external_dns)]
}
