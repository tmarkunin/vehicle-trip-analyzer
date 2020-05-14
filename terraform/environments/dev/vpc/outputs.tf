output "outputs" {
  value = module.vpc
}
output "admin_sg" {
  value = aws_security_group.admin
}

