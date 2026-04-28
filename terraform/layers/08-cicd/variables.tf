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

variable "harbor_registry_url" {
  type    = string
  default = "harbor.example.com"
}

variable "harbor_robot_secret_name" {
  type    = string
  default = "team9-mini/harbor/robot"
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-terraform-state-dev"
}

variable "terraform_state_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "platform_state_key" {
  type    = string
  default = "04-platform-eks/terraform.tfstate"
}
