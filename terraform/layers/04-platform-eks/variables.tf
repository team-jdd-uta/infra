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

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-terraform-state-dev"
}

variable "terraform_state_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "foundation_state_key" {
  type    = string
  default = "02-foundation/terraform.tfstate"
}

variable "general_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "build_node_instance_types" {
  type    = list(string)
  default = ["m6i.xlarge"]
}
