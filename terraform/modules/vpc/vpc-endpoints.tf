# VPC Endpoint for S3
data "aws_vpc_endpoint_service" "s3" {
  count   = var.enable_s3_endpoint ? 1 : 0
  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id       = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  tags         = local.vpce_tags
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

resource "aws_vpc_endpoint_route_table_association" "public_additional_s3" {
  count = var.enable_s3_endpoint && length(var.public_subnets_additional) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public_additional[0].id
}

# VPC Endpoint for API Gateway
data "aws_vpc_endpoint_service" "apigw" {
  count   = var.enable_apigw_endpoint ? 1 : 0
  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  count = var.enable_apigw_endpoint ? 1 : 0

  vpc_id            = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.apigw[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = var.apigw_endpoint_security_group_ids
  subnet_ids = coalescelist(var.apigw_endpoint_subnet_ids, [
    //put eks subnets here
  ])
  private_dns_enabled = var.apigw_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}