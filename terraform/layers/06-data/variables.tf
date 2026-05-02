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
  default = "3.7.x.kraft"
}

variable "msk_number_of_broker_nodes" {
  type    = number
  default = 3
}

variable "redis_node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "redis_num_node_groups" {
  type    = number
  default = 1
}

variable "redis_replicas_per_node_group" {
  type    = number
  default = 1
}

variable "documentdb_instance_class" {
  type    = string
  default = "db.r6g.large"
}

variable "enable_debezium_connector" {
  type    = bool
  default = false
}

variable "debezium_plugin_bucket_arn" {
  type    = string
  default = ""
}

variable "debezium_plugin_file_key" {
  type    = string
  default = ""
}

variable "msk_connect_kafkaconnect_version" {
  type    = string
  default = "3.7.x"
}

variable "debezium_mcu_count" {
  type    = number
  default = 1
}

variable "debezium_worker_count" {
  type    = number
  default = 1
}

variable "debezium_tasks_max" {
  type    = number
  default = 1
}

variable "debezium_database_server_id" {
  type    = string
  default = "5401"
}

variable "debezium_database_include_list" {
  type    = string
  default = "app1"
}

variable "debezium_topic_prefix" {
  type    = string
  default = "team9.dbserver1"
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
