terraform {
  backend "s3" {
    bucket         = "vehicle-trip-analyzer"
    key            = "vehicle-trip-analyzer/base_naming.tfstate"
    region         = "eu-central-1"
    profile        = "default"
    dynamodb_table = "terraform-state-lock"
  }
}
