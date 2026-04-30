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

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_region
  common_tags                = var.common_tags
  db_instance_count          = var.db_instance_count
  msk_broker_instance_type   = var.msk_broker_instance_type
  msk_kafka_version          = var.msk_kafka_version
  msk_number_of_broker_nodes = var.msk_number_of_broker_nodes
  documentdb_instance_class  = var.documentdb_instance_class
  vpc_id                     = data.terraform_remote_state.foundation.outputs.vpc_id
  private_data_subnet_ids    = data.terraform_remote_state.foundation.outputs.private_data_subnet_ids
  kms_key_arn                = data.terraform_remote_state.foundation.outputs.kms_key_arn
  node_security_group_id     = data.terraform_remote_state.platform.outputs.node_security_group_id
}
