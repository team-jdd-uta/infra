module "auth" {
  source = "../../modules/auth"

  project_name                       = var.project_name
  environment                        = var.environment
  aws_region                         = var.aws_region
  common_tags                        = var.common_tags
  oidc_provider_arn                  = data.terraform_remote_state.platform.outputs.oidc_provider_arn
  oidc_issuer_url                    = data.terraform_remote_state.platform.outputs.oidc_issuer_url
  login_service_namespace            = var.login_service_namespace
  login_service_service_account_name = var.login_service_service_account_name
  cognito_password_minimum_length    = var.cognito_password_minimum_length
}
