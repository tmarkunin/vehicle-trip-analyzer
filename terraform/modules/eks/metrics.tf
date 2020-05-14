resource "helm_release" "metrics_server" {
  depends_on = [aws_autoscaling_group.workers]
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/metrics-server"

  set {
    name  = "args"
    value = "{${join(",", ["--kubelet-insecure-tls", "--kubelet-preferred-address-types=InternalIP"])}}"
  }
}
