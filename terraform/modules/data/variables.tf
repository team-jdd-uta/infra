variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "db_instance_count" {
  type = number
}

variable "msk_broker_instance_type" {
  type = string
}

variable "msk_kafka_version" {
  type = string
}

variable "msk_number_of_broker_nodes" {
  type = number
}

variable "documentdb_instance_class" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "kms_key_arn" {
  type = string
}

variable "node_security_group_id" {
  type = string
}
