data "aws_caller_identity" "aws" {
  provider = aws
}

terraform {
  backend "s3" {
    bucket         = "vehicle-trip-analyzer"
    key            = "vehicle-trip-analyzer/vpc.tfstate"
    region         = "us-east-1"
    profile        = "vehicle-trip-analyzer"
    dynamodb_table = "terraform-state-lock"
  }
}
