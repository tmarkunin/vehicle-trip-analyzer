resource "aws_security_group" "admin" {
  name        = "admin"
  description = "Security Group Administration"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    module.tags.tags,
    {
      Name = "${module.tags.id}-admin-sg"
    }
  )
}

resource "aws_security_group_rule" "admin-ingress1" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.168.110.0/26", "10.169.228.0/23", "10.148.200.20/32", "10.149.102.0/23", "10.149.109.64/27", "10.149.144.0/24"]
  security_group_id = aws_security_group.admin.id
}

resource "aws_security_group" "infra" {
  name        = "infra"
  description = "Security Group Infrastructure"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    module.tags.tags,
    {
      Name = "${module.tags.id}-infra-sg"
    }
  )
}
