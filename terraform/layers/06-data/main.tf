data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.foundation_state_key
    region = var.terraform_state_region
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.platform_state_key
    region = var.terraform_state_region
  }
}

module "data" {
  source = "../../modules/data"

  project_name                     = var.project_name
  environment                      = var.environment
  aws_region                       = var.aws_region
  common_tags                      = var.common_tags
  db_instance_count                = var.db_instance_count
  msk_broker_instance_type         = var.msk_broker_instance_type
  msk_kafka_version                = var.msk_kafka_version
  msk_number_of_broker_nodes       = var.msk_number_of_broker_nodes
  documentdb_instance_class        = var.documentdb_instance_class
  enable_debezium_connector        = var.enable_debezium_connector
  debezium_plugin_bucket_arn       = var.debezium_plugin_bucket_arn
  debezium_plugin_file_key         = var.debezium_plugin_file_key
  msk_connect_kafkaconnect_version = var.msk_connect_kafkaconnect_version
  debezium_mcu_count               = var.debezium_mcu_count
  debezium_worker_count            = var.debezium_worker_count
  debezium_tasks_max               = var.debezium_tasks_max
  debezium_database_server_id      = var.debezium_database_server_id
  debezium_database_include_list   = var.debezium_database_include_list
  debezium_topic_prefix            = var.debezium_topic_prefix
  vpc_id                           = data.terraform_remote_state.foundation.outputs.vpc_id
  private_data_subnet_ids          = data.terraform_remote_state.foundation.outputs.private_data_subnet_ids
  kms_key_arn                      = data.terraform_remote_state.foundation.outputs.kms_key_arn
  node_security_group_id           = data.terraform_remote_state.platform.outputs.node_security_group_id
}
