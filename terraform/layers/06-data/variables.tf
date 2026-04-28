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

variable "db_instance_count" {
  type    = number
  default = 3
}

variable "redis_node_type" {
  type    = string
  default = "cache.r7g.large"
}

variable "documentdb_instance_class" {
  type    = string
  default = "db.r6g.large"
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

variable "platform_state_key" {
  type    = string
  default = "04-platform-eks/terraform.tfstate"
}
