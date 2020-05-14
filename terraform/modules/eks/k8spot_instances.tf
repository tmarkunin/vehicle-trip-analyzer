resource "helm_release" "k8s_spot" {
  count      = var.enable_spot_instances ? 1 : 0
  depends_on = [aws_autoscaling_group.workers]
  name       = "k8s-spot-termination-handler"
  namespace  = "kube-system"
  chart      = "stable/k8s-spot-termination-handler"
}
