module "base_naming" {
  source              = "./modules/naming"
  environment         = var.env
  product_name        = var.product_name
  instance_name       = var.instance_name
  owner               = var.product_owner
  allowed_chars_regex = var.allowed_chars_regex
}
