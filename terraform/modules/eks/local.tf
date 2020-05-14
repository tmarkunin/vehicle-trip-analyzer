locals {
  asg_tags           = null_resource.tags_as_list_of_maps.*.triggers
  worker_group_count = length(var.worker_groups)
  cni_rendered = templatefile("${path.module}/templates/aws-k8s-cni.yaml.tpl", {
    environment = var.cni_configuration
  })
}
