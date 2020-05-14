resource "null_resource" "delay_auth" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [aws_autoscaling_group.workers]
}


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = format("%s%s", join("", distinct(data.template_file.worker_role_arns.*.rendered)), length(var.map_roles) > 0 ? yamlencode(var.map_roles) : "")
    mapUsers    = length(var.map_users) > 0 ? yamlencode(var.map_users) : ""
    mapAccounts = length(var.map_accounts) > 0 ? yamlencode(var.map_accounts) : ""
  }

  depends_on = [null_resource.delay_auth]
}