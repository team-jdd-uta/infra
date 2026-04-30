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

variable "msk_broker_instance_type" {
  type    = string
  default = "kafka.m7g.large"
}

variable "msk_kafka_version" {
  type    = string
  default = "3.7.x"
}

variable "msk_number_of_broker_nodes" {
  type    = number
  default = 3
}

variable "documentdb_instance_class" {
  type    = string
  default = "db.r6g.large"
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-dev-terraform-state"
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
