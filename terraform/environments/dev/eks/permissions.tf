data "aws_eks_cluster_auth" "this" {
  depends_on = [module.eks]
  name       = var.eks_cluster_name
}

data "aws_eks_cluster" "this" {
  depends_on = [module.eks]
  name       = var.eks_cluster_name
}

resource "kubernetes_cluster_role_binding" "read-only" {
  depends_on = [module.eks]
  #  provider   = "kubernetes"
  metadata {
    name = "read-only-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "ReadOnly"
    api_group = "rbac.authorization.k8s.io"
  }
}
