resource "kubernetes_namespace" "istio" {
  count = var.enable_istio ? 1 : 0
  metadata {
    annotations = {
      name = "istio-system"
    }
    name = "istio-system"
  }
}

data "helm_repository" "istio" {
  count = var.enable_istio ? 1 : 0
  name  = "istio.io"
  url   = "https://storage.googleapis.com/istio-release/releases/${var.istio_version}/charts/"
}

resource "helm_release" "istio-init" {
  count      = var.enable_istio ? 1 : 0
  name       = "istio-init"
  namespace  = kubernetes_namespace.istio[0].metadata.0.name
  repository = data.helm_repository.istio[0].url
  version    = var.istio_version
  chart      = "istio-init"
}

resource "null_resource" "delay" {
  count = var.enable_istio ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [helm_release.istio-init]
}

resource "helm_release" "istio" {
  count      = var.enable_istio ? 1 : 0
  name       = "istio"
  repository = data.helm_repository.istio[0].url
  chart      = "istio"
  version    = var.istio_version
  namespace  = kubernetes_namespace.istio[0].metadata.0.name

  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "true"
  }

  depends_on = [
    helm_release.istio-init,
    null_resource.delay
  ]

  /* 
# Experimantal internal network load balancer
  set {
    name = "istio-ingressgateway.serviceAnnotations.\"service.beta.kubernetes.io/aws-load-balancer-internal\""
    value = "0.0.0.0/0"
  }

  set {
    name = "istio-ingressgateway.serviceAnnotations.\"service.beta.kubernetes.io/aws-load-balancer-type\""
    value = "nlb"
  }
  */
}
