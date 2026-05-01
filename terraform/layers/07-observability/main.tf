module "observability" {
  source = "../../modules/observability"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  common_tags               = var.common_tags
  slack_webhook_secret_name = var.slack_webhook_secret_name
  grafana_hostname          = var.grafana_hostname
  ingress_certificate_arn   = data.terraform_remote_state.edge.outputs.alb_ingress_certificate_arn
}
