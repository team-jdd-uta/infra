module "cicd" {
  source = "../../modules/cicd"

  project_name                               = var.project_name
  environment                                = var.environment
  aws_region                                 = var.aws_region
  common_tags                                = var.common_tags
  oidc_provider_arn                          = data.terraform_remote_state.platform.outputs.oidc_provider_arn
  oidc_issuer_url                            = data.terraform_remote_state.platform.outputs.oidc_issuer_url
  ecr_backend_repository_names               = var.ecr_backend_repository_names
  ecr_legacy_repository_names                = var.ecr_legacy_repository_names
  jenkins_git_credentials_id                 = var.jenkins_git_credentials_id
  jenkins_admin_secret_name                  = var.jenkins_admin_secret_name
  jenkins_admin_k8s_secret_name              = var.jenkins_admin_k8s_secret_name
  jenkins_git_credentials_secret_name        = var.jenkins_git_credentials_secret_name
  jenkins_git_k8s_secret_name                = var.jenkins_git_k8s_secret_name
  jenkins_hostname                           = var.jenkins_hostname
  external_secrets_cluster_secret_store_name = var.external_secrets_cluster_secret_store_name
  frontend_pipeline_job_name                 = var.frontend_pipeline_job_name
  frontend_pipeline_repo_url                 = var.frontend_pipeline_repo_url
  frontend_pipeline_repo_branch              = var.frontend_pipeline_repo_branch
  frontend_pipeline_jenkinsfile_path         = var.frontend_pipeline_jenkinsfile_path
  backend_pipeline_repositories              = var.backend_pipeline_repositories
  jenkins_kaniko_service_account_name        = var.jenkins_kaniko_service_account_name
}
