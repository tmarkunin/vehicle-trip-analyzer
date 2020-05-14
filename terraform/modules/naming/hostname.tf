##############################
# Hostname
##############################
locals {
  hostname_draft = var.create_hostname ? "${local.application_name}${var.placeholder}-${var.product_name_short[local.product_name]}-${local.instance_name}-${local.environment}-${var.region_short[local.region]}.${local.sub_domain}.${local.root_domain}" : ""
  hostname       = replace(local.hostname_draft, "/[\\-]+/", "-")

  region      = length(var.region) > 0 ? var.region : data.aws_region.this.name
  sub_domain  = lower(replace(coalesce(var.sub_domain, var.context.sub_domain, data.aws_caller_identity.this.account_id, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  root_domain = lower(replace(coalesce(var.root_domain, var.context.root_domain, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}