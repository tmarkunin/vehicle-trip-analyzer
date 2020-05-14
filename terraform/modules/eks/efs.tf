/* EFS Security group rule */
# resource "aws_security_group_rule" "workers_to_efs" {
#   count = var.enable_efs ? 1 : 0
#   description = "Allow workers to connect to EFS"
#   protocol = "tcp"
#   security_group_id = var.efs_sg
#   source_security_group_id = aws_security_group.workers.id
#   from_port = 2049
#   to_port = 2049
#   type = "ingress"
# }

# resource "helm_release" "efs" {
#   depends_on = [aws_autoscaling_group.workers]
#   name       = "efs-provisioner"
#   namespace  = "kube-system"
#   chart      = "stable/efs-provisioner"

#   set {
#       name = "efsProvisioner.efsFileSystemId"
#       value = var.efs_id
#   }

#   set {
#       name = "efsProvisioner.awsRegion"
#       value = var.region
#   }
# }
