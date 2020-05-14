data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "vehicle-trip-analyzer/vpc.tfstate"
    region = var.region
  }
}
