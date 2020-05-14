# resource "helm_release" "autoscaler" {
#   depends_on = [aws_autoscaling_group.workers]
#   name       = "autoscaler"
#   namespace  = "kube-system"
#   chart      = "stable/cluster-autoscaler"

#   set {
#     name  = "awsRegion"
#     value = "${var.region}"
#   }

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = "${var.cluster_name}"
#   }

#   set {
#     name  = "autoDiscovery.enabled"
#     value = "true"
#   }

#   set {
#     name  = "sslCertPath"
#     value = "etc/ssl/certs/ca-bundle.crt"
#   }

#   set {
#     name  = "rbac.create"
#     value = "true"
#   }
# }

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}


resource "helm_release" "autoscaler" {
  name       = "autoscaler"
  namespace  = "kube-system"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "sslCertPath"
    value = "/etc/kubernetes/pki/ca.crt"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = [null_resource.delay_auth]
}
