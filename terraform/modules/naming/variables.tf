##############################
# General
##############################
variable "enabled" {
  description = "(Optional) Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "resource_name" {
  description = "(Optional) AWS Resource name, e.g. \"ec2\" or \"vpc\""
  type        = string
  default     = ""
}

variable "allowed_chars_regex" {
  description = "Allowed chars. By default only letters, digits and hyphens are allowed, all other chars will be removed."
  type        = string
  default     = "/[^a-zA-Z0-9-]/"
}

variable "delimiter" {
  description = "Delimiter to be used between naming parts."
  type        = string
  default     = "-"
}

variable "label_order" {
  description = "The order of labels by naming convention"
  type        = list(string)
  default     = []
}

##############################
# Project specific
##############################
variable "owner" {
  description = "(Required) Owner. Individual: e.g. DBA Lead name, Product Arch/Lead name or Team / Business Unit"
  type        = string
  default     = ""
}

variable "product_name" { // <product_name>
  description = "(Required) Product name. Used for billing and automation."
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "The name of the instance of the product: qa1, devint7, mybranch4. Used for automation"
  type        = string
  default     = ""
}

variable "application_name" { // <app_name>-<build_version>
  description = "Application name & Build Version"
  type        = string
  default     = ""
}

variable "environment" { // <Env>
  description = "(Required) Environment name (\"dev\", \"qa\", \"prod\", etc). Used for billing"
  type        = string
  default     = ""
}

variable "security_domain" { // <SecurityLevel>
  description = "(Optional) Identifier for compliance (HIPAA, etc)"
  type        = string
  default     = ""
}

variable "customer" { // <OrgID-TenantID>
  description = "(Optional) Customer name"
  type        = string
  default     = ""
}

variable "inspector_target" {
  description = "(Required) Tag for AWS Inspector service (see Security section)"
  type        = string
  default     = "ALL"
}

##############################
# Tagging
##############################

variable "attribute" {
  description = "Additional attribute"
  type        = string
  default     = ""
}

variable "tags" {
  description = "General tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags for appending to each tag map."
  type        = map(string)
  default     = {}
}

##############################
# Context
##############################
variable "context" {
  description = "Context for passing between modules."
  type = object({
    owner               = string
    product_name        = string
    resource_name       = string
    instance_name       = string
    application_name    = string
    environment         = string
    security_domain     = string
    customer            = string
    inspector_target    = string
    enabled             = bool
    delimiter           = string
    attribute           = string
    tags                = map(string)
    additional_tag_map  = map(string)
    label_order         = list(string)
    allowed_chars_regex = string
    sub_domain          = string
    root_domain         = string
  })

  default = {
    owner               = ""
    product_name        = ""
    resource_name       = ""
    instance_name       = ""
    application_name    = ""
    environment         = ""
    security_domain     = ""
    customer            = ""
    inspector_target    = ""
    enabled             = true
    delimiter           = ""
    attribute           = ""
    tags                = {}
    additional_tag_map  = {}
    label_order         = []
    allowed_chars_regex = ""
    sub_domain          = ""
    root_domain         = ""
  }
}

##############################
# Hostname // https://confluence.acoustic.co/pages/viewpage.action?pageId=32899278
##############################
variable "region" {
  type        = string
  description = "(Optional) AWS region to use."
  default     = ""
}

variable "create_hostname" {
  type        = bool
  description = "(Optional) Whether to generate a hostname"
  default     = false
}

variable "placeholder" {
  type        = string
  description = "(Optional) Placeholder"
  default     = "[:PLACEHOLDER:]"
}

variable "sub_domain" {
  type        = string
  description = "(Optional) Subdomain. By default it is an id of current AWS account"
  default     = ""
}

variable "root_domain" {
  type        = string
  description = "(Optional) Domain root 'awsnp' for non-prod. Domain root 'awspr' for prod"
  default     = "awsnp"
}

variable "product_name_short" {
  description = "Shortening version of product name"
  type        = map(string)
  default = {
    journey                 = "ja"
    exchange                = "exch"
    personalization         = "pzn"
    services                = "services"
    discovery               = "disc"
    secops                  = "secops"
    devops                  = "devops"
    network                 = "network"
    poc                     = "poc"
  }
}

variable "region_short" {
  description = "(Optional) Shortening version of aws region"
  type        = map(string)
  default = {
    us-east-1      = "ue1"
    us-east-2      = "ue2"
    us-west-1      = "uw1"
    us-west-2      = "uw2"
    ap-south-1     = "as1"
    ap-southeast-1 = "ase1"
    ap-southeast-2 = "ase2"
    ca-central-1   = "cc1"
    eu-central-1   = "ec1"
    eu-west-1      = "ew1"
  }
}
