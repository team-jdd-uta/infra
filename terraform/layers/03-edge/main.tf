module "edge" {
  source = "../../modules/edge"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  common_tags          = var.common_tags
  root_domain_name     = var.root_domain_name
  frontend_domain_name = var.frontend_domain_name
  price_class          = var.price_class
}
