locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "bootstrap_backend" {
  source = "../../modules/bootstrap-backend"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  common_tags  = var.common_tags
}
