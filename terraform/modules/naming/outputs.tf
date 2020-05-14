output "id" {
  value       = local.enabled ? local.id : ""
  description = "Normalized id by naming convention"
}

output "owner" {
  value = local.owner
}

output "product_name" {
  value = local.product_name
}

output "environment" {
  value       = local.environment
  description = "Normalized environment name."
}

output "resource_name" {
  value = local.resource_name
}

output "instance_name" {
  value = local.instance_name
}

output "application_name" {
  value = local.application_name
}

output "security_domain" {
  value = local.security_domain
}

output "customer" {
  value = local.customer
}

output "inspector_target" {
  value = local.inspector_target
}

output "tags" {
  value       = local.enabled ? local.tags : {}
  description = "Normalized tag map"
}

output "tags_as_list_of_map" {
  value       = local.enabled ? local.tags_as_list_of_map : []
  description = "Tag as list of maps include additioal tags map."
}

output "context" {
  value       = local.output_context
  description = "Context of current module to pass to child naming modules."
}

output "attribute" {
  value = local.attribute
}

output "hostname" {
  value = local.hostname
}

output "placeholder" {
  value = var.placeholder
}



