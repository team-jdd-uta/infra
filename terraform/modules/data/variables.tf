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

variable "enable_debezium_connector" {
  type = bool
}

variable "debezium_plugin_bucket_arn" {
  type = string
}

variable "debezium_plugin_file_key" {
  type = string
}

variable "msk_connect_kafkaconnect_version" {
  type = string
}

variable "debezium_mcu_count" {
  type = number
}

variable "debezium_worker_count" {
  type = number
}

variable "debezium_tasks_max" {
  type = number
}

variable "debezium_database_server_id" {
  type = string
}

variable "debezium_database_include_list" {
  type = string
}

variable "debezium_topic_prefix" {
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
