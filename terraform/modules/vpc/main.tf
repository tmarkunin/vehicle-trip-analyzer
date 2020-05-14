locals {
  public_subnets_amount = length(var.public_subnets)

  max_subnet_length = max(
    length(var.public_subnets),
    0
  )

  nat_gateway_count = var.single_nat_gateway ? 1 : local.azs_count

  vpce_tags = merge(
    var.tags,
    var.vpc_endpoint_tags,
  )


  azs_count = length(data.aws_availability_zones.available.names) < local.max_subnet_length ? length(data.aws_availability_zones.available.names) : local.max_subnet_length
  azs       = length(var.azs) == 0 ? slice(data.aws_availability_zones.available.names, 0, local.azs_count) : slice(var.azs, 0, local.azs_count)
}

data "aws_availability_zones" "available" {}

######
# VPC
######
resource "aws_vpc" "this" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    var.tags,
    var.dhcp_options_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    var.tags,
    var.igw_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################
# Publiс routes additional
################
resource "aws_route_table" "public_additional" {
  count = var.public_subnets_additional_own_rt ? length(var.public_subnets_additional) : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    var.tags,
    var.public_route_table_additional_tags,
    {
      "Name" = format("%s-${var.public_subnet_additional_suffix}", var.name)
    },
  )
}

resource "aws_route" "public_internet_gateway_additional" {
  count = var.public_subnets_additional_own_rt ? length(var.public_subnets_additional) : 0

  route_table_id         = aws_route_table.public_additional[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = local.private_subnets_amount > 0 ? local.nat_gateway_count : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = format("%s-${var.private_subnet_suffix}-%s", var.name, element(local.azs, count.index))
    },
  )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

resource "aws_route_table" "private-standalone-nat" {
  count = local.standalone_nat_gateway_count

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = format("%s-${var.private_subnet_suffix}-%s-%s-standalone", var.name, element(local.azs, count.index), element(local.standalone_by_type, floor(count.index / local.azs_count)))
    },
  )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id            = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(local.azs, count.index)
  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      "Name" = format("%s-${var.public_subnet_suffix}-%s", var.name, element(local.azs, count.index))
    },
  )
}

################
# Public subnet additional
################
resource "aws_subnet" "public_additional" {
  count = local.public_subnets_additional_amount > 0 ? local.public_subnets_additional_amount : 0

  vpc_id            = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block        = element(local.public_subnets_flatten.*.subnet, count.index)
  availability_zone = element(local.public_subnets_flatten.*.az, count.index)
  tags = merge(
    var.tags,
    local.public_subnets_flatten[count.index]["tags"],
    {
      "Name"                        = format("%s-${var.public_subnet_additional_suffix}-%s", var.name, element(local.azs, count.index))
      "${var.subnet_type_tag_name}" = local.public_subnets_flatten[count.index]["subnet_type"]
    },
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = local.private_subnets_amount > 0 ? local.private_subnets_amount : 0

  vpc_id            = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block        = local.private_subnets_flatten[count.index]["subnet"]
  availability_zone = local.private_subnets_flatten[count.index]["az"]
  tags = merge(
    var.tags,
    {
      "StandaloneNat" = local.private_subnets_flatten[count.index]["standalone_nat"]
    },
    local.private_subnets_flatten[count.index]["tags"],
    {
      "Name"                        = format("%s-${local.private_subnets_flatten[count.index]["subnet_type"]}-%s", var.name, local.private_subnets_flatten[count.index]["az"])
      "${var.subnet_type_tag_name}" = local.private_subnets_flatten[count.index]["subnet_type"]
    },
  )
}

##################
# EIP
##################
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  vpc = true

  tags = merge(
    var.tags,
    var.nat_eip_tags,
    {
      "Name" = format("%s-%s", var.name, element(local.azs, count.index))
    },
  )
}

resource "aws_eip" "nat-standalone" {
  count = local.standalone_nat_gateway_count

  vpc = true

  tags = merge(
    var.tags,
    var.nat_eip_tags,
    {
      "Name" = format("%s-%s-%s", var.name, element(local.azs, count.index), element(local.standalone_by_type, floor(count.index / local.azs_count)))
    },
  )
}
##################
# NAT
##################
resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? 1 : local.nat_gateway_count

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(

    var.tags,
    var.nat_gateway_tags,
    {
      "Name" = format("%s-%s", var.name, element(local.azs, count.index))
    },
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "standalone" {
  count = local.standalone_nat_gateway_count

  allocation_id = element(aws_eip.nat-standalone.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(

    var.tags,
    var.nat_gateway_tags,
    {
      "Name" = format("%s-%s-%s-standalone", var.name, element(local.azs, count.index), element(local.standalone_by_type, floor(count.index / local.azs_count)))
    },
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = local.nat_gateway_count + local.standalone_nat_gateway_count

  route_table_id         = count.index < local.nat_gateway_count ? element(aws_route_table.private.*.id, count.index) : element(aws_route_table.private-standalone-nat.*.id, count.index - local.nat_gateway_count)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = count.index < local.nat_gateway_count ? element(aws_nat_gateway.this.*.id, count.index) : element(aws_nat_gateway.standalone.*.id, count.index - local.nat_gateway_count)

  timeouts {
    create = "5m"
  }
}

locals {

  general_private_subnets = flatten([
    for subnet in aws_subnet.private :
    subnet["id"]
    if lookup(subnet["tags"], "StandaloneNat", "false") == "false"
  ])

  general_private_subnets_count = length(local.general_private_subnets)

  standalone_nat_private_subnets = flatten([
    for subnet in aws_subnet.private :
    subnet["id"]
    if lookup(subnet["tags"], "StandaloneNat", "false") == "true"
  ])
  standalone_nat_gateway_count = min(local.max_subnet_length, local.standalone_nat_private_subnets_count) * local.standalone_type_count

  standalone_nat_private_subnets_count = length(local.standalone_nat_private_subnets)

  standalone_type_count = length(local.standalone_by_type)
  standalone_by_type = flatten([
    for subnet_type, subnet_params in var.private_subnets :
    subnet_type
    if lookup(subnet_params, "standalone_nat", false) == true
  ])
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = local.private_subnets_amount > 0 ? local.general_private_subnets_count + local.standalone_nat_private_subnets_count : 0

  subnet_id      = count.index < local.general_private_subnets_count ? element(local.general_private_subnets, count.index) : element(local.standalone_nat_private_subnets, count.index - local.general_private_subnets_count)
  route_table_id = count.index < local.general_private_subnets_count ? element(aws_route_table.private.*.id, count.index % length(aws_route_table.private)) : element(aws_route_table.private-standalone-nat.*.id, (count.index - local.general_private_subnets_count))
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public_additional" {
  count = local.public_subnets_additional_amount > 0 ? local.public_subnets_additional_amount : 0

  subnet_id      = element(aws_subnet.public_additional.*.id, count.index)
  route_table_id = var.public_subnets_additional_own_rt ? element(aws_route_table.public_additional.*.id, local.public_subnets_flatten[count.index]["set_index"]) : aws_route_table.public[0].id
}