variable "project_name" {
  type    = string
  default = "team9-mini"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  type    = string
  default = "team9-mini-dev-eks"
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-dev-terraform-state"
}

variable "terraform_state_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "platform_state_key" {
  type    = string
  default = "04-platform-eks/terraform.tfstate"
}

variable "foundation_state_key" {
  type    = string
  default = "02-foundation/terraform.tfstate"
}

variable "root_domain_name" {
  type    = string
  default = "example.com"
}

variable "cert_manager_email" {
  type    = string
  default = "platform@example.com"
}
