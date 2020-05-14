resource "helm_release" "kubernetes_dashboard" {
  count      = var.enable_kubernetes_dashboard ? 1 : 0
  depends_on = [aws_autoscaling_group.workers]
  name       = "kubernetes-dashboard"
  # namespace  = "kube-system"
  chart = "stable/kubernetes-dashboard"

  values = var.path_to_values_kubernetes_dashboard == null ? [] : [file(var.path_to_values_kubernetes_dashboard)]
}
