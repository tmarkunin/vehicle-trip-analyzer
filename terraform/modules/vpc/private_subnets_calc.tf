locals {
  private_subnets_by_types_length = {
    for subnet_type in keys(var.private_subnets) :
    subnet_type => length(var.private_subnets[subnet_type]["subnets"])
    if length(var.private_subnets[subnet_type]["subnets"]) > 0
  }

  private_subnets_amount = length(flatten([
    for number in values(local.private_subnets_by_types_length) : range(number) // https://github.com/hashicorp/terraform/issues/17239#issuecomment-521850389
  ]))

  private_subnets_max_length = local.private_subnets_by_types_length == {} ? 0 : max(flatten([values(local.private_subnets_by_types_length)])...)

  private_subnets_flatten = flatten([
    for subnet_type, subnet_params in var.private_subnets : [
      for subnet in subnet_params.subnets : {
        subnet         = subnet
        subnet_type    = var.private_lex_order == false ? replace(subnet_type, regex(var.order_prefex_regex, subnet_type), "") : subnet_type
        subnet_index   = index(subnet_params.subnets, subnet)
        az             = local.azs[index(subnet_params.subnets, subnet) < length(local.azs) ? index(subnet_params.subnets, subnet) : index(subnet_params.subnets, subnet) % (length(local.azs))]
        tags           = lookup(subnet_params, "tags", {})
        standalone_nat = lookup(subnet_params, "standalone_nat", false)
      }
    ]
  ])

  private_subnets_aws_result = flatten([
    for index, subnet_params in aws_subnet.private : [
      {
        "${subnet_params.cidr_block}" = {
          id          = subnet_params.id
          cidr_block  = subnet_params.cidr_block
          arn         = subnet_params.arn
          az          = subnet_params.availability_zone
          subnet_type = lookup(local.private_subnets_type_by_cidr_map, subnet_params.cidr_block, lookup(subnet_params.tags, var.subnet_type_tag_name, ""))
        }
      }
    ]
  ])

  private_subnets_type_by_cidr_map = {
    for subnet in local.private_subnets_flatten :
    subnet["subnet"] => subnet["subnet_type"]
  }

  private_subnets_compound = flatten([
    for index, subnet_params in aws_subnet.private : [
      {
        "${lookup(local.private_subnets_type_by_cidr_map, subnet_params.cidr_block, lookup(subnet_params.tags, var.subnet_type_tag_name, ""))}" = {
          id          = subnet_params.id
          cidr_block  = subnet_params.cidr_block
          arn         = subnet_params.arn
          az          = subnet_params.availability_zone
          subnet_type = lookup(local.private_subnets_type_by_cidr_map, subnet_params.cidr_block, lookup(subnet_params.tags, var.subnet_type_tag_name, ""))
        }
      }
    ]
  ])

  private_subnets_compound_flat = { for s in local.private_subnets_compound : keys(tomap(s))[0] => values(tomap(s))... }

  private_subnets_compound_as_list = [
    for k, v in local.private_subnets_compound_flat : {
      "${k}" = [
        for s in v : {
          ids        = s[0]["id"]
          arn        = s[0]["arn"]
          cidr_block = s[0]["cidr_block"]
      }]
    }
  ]

  private_subnets_compound_as_map = {
    for t in local.private_subnets_compound_as_list :
    keys(tomap(t))[0] => values(tomap(t))[0]
  }

}


