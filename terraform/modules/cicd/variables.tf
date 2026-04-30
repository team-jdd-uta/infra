variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "ecr_frontend_repository_name" {
  type = string
}

variable "ecr_backend_repository_names" {
  type = list(string)
}

variable "jenkins_admin_username" {
  type = string
}

variable "jenkins_admin_password" {
  type = string
}

variable "jenkins_git_credentials_id" {
  type = string
}

variable "jenkins_git_username" {
  type = string
}

variable "jenkins_git_token" {
  type = string
}

variable "frontend_pipeline_job_name" {
  type = string
}

variable "frontend_pipeline_repo_url" {
  type = string
}

variable "frontend_pipeline_repo_branch" {
  type = string
}

variable "frontend_pipeline_jenkinsfile_path" {
  type = string
}

variable "backend_pipeline_repositories" {
  type = list(object({
    job_name         = string
    repo_url         = string
    branch           = string
    jenkinsfile_path = string
  }))
}
