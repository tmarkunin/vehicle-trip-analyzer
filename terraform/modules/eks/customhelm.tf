data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "custom_helm" {
  count = length(var.custom_name) != 0 ? length(var.custom_name) : 0

  name      = var.custom_name[count.index]
  namespace = var.custom_namespace[count.index]
  chart     = var.custom_chart[count.index]

  values = var.custom_path[count.index] == null ? [] : [file(var.custom_path[count.index])]
}
