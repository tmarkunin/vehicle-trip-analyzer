locals {
  defaults = {
    label_order = ["product_name", "environment", "resource_name", "instance_name", "application_name", "attribute"]
    delimiter   = "-"
    replacement = ""
    sentinel    = "~"
    attrinute   = ""
  }

  enabled             = var.enabled
  allowed_chars_regex = var.allowed_chars_regex
  delimiter           = coalesce(var.delimiter, var.context.delimiter, local.defaults.delimiter)
  label_order         = length(var.label_order) > 0 ? var.label_order : (length(var.context.label_order) > 0 ? var.context.label_order : local.defaults.label_order)

  ##############################
  # Id
  ##############################
  id_context = { // <product_name>-<env>-<instance_name>-<app_name>-<count>
    owner            = local.owner
    product_name     = local.product_name // product name
    environment      = local.environment  // environment name
    resource_name    = local.resource_name
    instance_name    = local.instance_name    // the instance of the product
    application_name = local.application_name // application name
    attribute        = local.attribute
  }

  label = [
    for label in local.label_order :
    local.id_context[label] if length(local.id_context[label]) > 0
  ]

  id = lower(join(local.delimiter, local.label))


  owner            = lower(replace(coalesce(var.owner, var.context.owner, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  product_name     = lower(replace(coalesce(var.product_name, var.context.product_name, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  environment      = lower(replace(coalesce(var.environment, var.context.environment, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  resource_name    = lower(replace(coalesce(var.resource_name, var.context.resource_name, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  instance_name    = lower(replace(coalesce(var.instance_name, var.context.instance_name, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  application_name = lower(replace(coalesce(var.application_name, var.context.application_name, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  security_domain  = lower(replace(coalesce(var.security_domain, var.context.security_domain, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  customer         = lower(replace(coalesce(var.customer, var.context.customer, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))
  inspector_target = lower(replace(coalesce(var.inspector_target, var.context.inspector_target, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))

  attribute = lower(replace(coalesce(var.attribute, var.context.attribute, local.defaults.sentinel), local.allowed_chars_regex, local.defaults.replacement))

  ##############################
  # Tags
  ##############################
  tags_context = { // Foundation Architecture Design - Tagging strategy
    Name            = local.id
    Owner           = local.owner
    Product         = local.product_name
    Instance        = local.instance_name
    Application     = local.application_name
    Environment     = local.environment
    SecurityDomain  = local.security_domain
    Customer        = local.customer
    InspectorTarget = local.inspector_target
  }

  generated_tags = { // produce tags with values by Tagging strategy
    for key in keys(local.tags_context) :
    title(key) => local.tags_context[key] if length(local.tags_context[key]) > 0
  }

  tags = merge(var.context.tags, local.generated_tags, var.tags)

  ##############################
  # Additional tag map
  ##############################
  additional_tags = merge(var.context.additional_tag_map, var.additional_tags)

  tags_as_list_of_map_unmerged = flatten(
    [
      for k in keys(local.tags) :
      {
        key   = k
        value = local.tags[k]
      }
    ]
  )

  tags_as_list_of_map = [
    for tags in local.tags_as_list_of_map_unmerged :
    merge(tags, var.additional_tags)
  ]

  output_context = {
    owner               = local.owner
    product_name        = local.product_name
    resource_name       = local.resource_name
    instance_name       = local.instance_name
    application_name    = local.application_name
    environment         = local.environment
    security_domain     = local.security_domain
    customer            = local.customer
    inspector_target    = local.inspector_target
    enabled             = local.enabled
    delimiter           = local.delimiter
    attribute           = local.attribute
    tags                = local.tags
    additional_tag_map  = local.additional_tags
    label_order         = local.label_order
    allowed_chars_regex = local.allowed_chars_regex
    sub_domain          = local.sub_domain
    root_domain         = local.root_domain
  }
}