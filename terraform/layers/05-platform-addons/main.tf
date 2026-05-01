module "platform_addons" {
  source = "../../modules/platform-addons"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  common_tags        = var.common_tags
  cluster_name       = data.terraform_remote_state.platform.outputs.cluster_name
  oidc_provider_arn  = data.terraform_remote_state.platform.outputs.oidc_provider_arn
  oidc_issuer_url    = data.terraform_remote_state.platform.outputs.oidc_issuer_url
  vpc_id             = data.terraform_remote_state.foundation.outputs.vpc_id
  root_domain_name   = var.root_domain_name
  cert_manager_email = var.cert_manager_email
  argocd_hostname    = var.argocd_hostname

  slack_webhook_secret_name                  = var.slack_webhook_secret_name
  external_secrets_cluster_secret_store_name = var.external_secrets_cluster_secret_store_name
}
