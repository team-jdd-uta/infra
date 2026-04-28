module "cicd" {
  source = "../../modules/cicd"

  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  common_tags              = var.common_tags
  harbor_registry_url      = var.harbor_registry_url
  harbor_robot_secret_name = var.harbor_robot_secret_name
}
