data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.foundation_state_key
    region = var.terraform_state_region
  }
}

module "platform_eks" {
  source = "../../modules/platform-eks"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  common_tags                 = var.common_tags
  cluster_name                = var.cluster_name
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = data.terraform_remote_state.foundation.outputs.vpc_id
  vpc_cidr                    = data.terraform_remote_state.foundation.outputs.vpc_cidr
  private_app_subnet_ids      = data.terraform_remote_state.foundation.outputs.private_app_subnet_ids
  public_subnet_ids           = data.terraform_remote_state.foundation.outputs.public_subnet_ids
  general_node_instance_types = var.general_node_instance_types
  build_node_instance_types   = var.build_node_instance_types
}
