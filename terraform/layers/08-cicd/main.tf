module "cicd" {
  source = "../../modules/cicd"

  project_name                       = var.project_name
  environment                        = var.environment
  aws_region                         = var.aws_region
  common_tags                        = var.common_tags
  ecr_frontend_repository_name       = var.ecr_frontend_repository_name
  ecr_backend_repository_names       = var.ecr_backend_repository_names
  jenkins_admin_username             = var.jenkins_admin_username
  jenkins_admin_password             = var.jenkins_admin_password
  jenkins_git_credentials_id         = var.jenkins_git_credentials_id
  jenkins_git_username               = var.jenkins_git_username
  jenkins_git_token                  = var.jenkins_git_token
  frontend_pipeline_job_name         = var.frontend_pipeline_job_name
  frontend_pipeline_repo_url         = var.frontend_pipeline_repo_url
  frontend_pipeline_repo_branch      = var.frontend_pipeline_repo_branch
  frontend_pipeline_jenkinsfile_path = var.frontend_pipeline_jenkinsfile_path
  backend_pipeline_repositories      = var.backend_pipeline_repositories
}
