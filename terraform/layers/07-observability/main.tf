module "observability" {
  source = "../../modules/observability"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  common_tags               = var.common_tags
  slack_webhook_secret_name = var.slack_webhook_secret_name
}
