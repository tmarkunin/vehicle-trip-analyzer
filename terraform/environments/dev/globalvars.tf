provider aws {
  region  = var.region
  profile = var.profile
}

variable "env" {
  type    = string
  default = "dev"
}

variable "product_name" {
  type    = string
  default = "vehicle-trip-analyzer"
}

variable "product_owner" {
  type    = string
  default = "devops"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "bucket" {
  type    = string
  default = "vehicle-trip-analyzer"
}

variable "instance_name" {
  type    = string
  default = ""
}

variable "eks_cluster_name" {
  type    = string
  default = "vehicle-trip-analyzer-dev-eks"
}
