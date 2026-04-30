variable "project_name" {
  type    = string
  default = "team9-mini"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "ecr_frontend_repository_name" {
  type    = string
  default = "team9-frontend"
}

variable "ecr_backend_repository_names" {
  type = list(string)
  default = [
    "team9-backend-api-gateway",
    "team9-backend-auth",
    "team9-backend-user",
    "team9-backend-chat",
    "team9-backend-notification",
    "team9-backend-media",
    "team9-backend-admin",
  ]
}

variable "jenkins_admin_username" {
  type    = string
  default = "admin"
}

variable "jenkins_admin_password" {
  type    = string
  default = "change-me-admin-password"
}

variable "jenkins_git_credentials_id" {
  type    = string
  default = "gitops-scm-creds"
}

variable "jenkins_git_username" {
  type    = string
  default = "example-username"
}

variable "jenkins_git_token" {
  type    = string
  default = "example-token"
}

variable "frontend_pipeline_job_name" {
  type    = string
  default = "frontend-dev"
}

variable "frontend_pipeline_repo_url" {
  type    = string
  default = "https://github.com/example-org/team9-frontend.git"
}

variable "frontend_pipeline_repo_branch" {
  type    = string
  default = "main"
}

variable "frontend_pipeline_jenkinsfile_path" {
  type    = string
  default = "Jenkinsfile"
}

variable "backend_pipeline_repositories" {
  type = list(object({
    job_name         = string
    repo_url         = string
    branch           = string
    jenkinsfile_path = string
  }))
  default = [
    {
      job_name         = "backend-api-gateway-dev"
      repo_url         = "https://github.com/example-org/team9-backend-api-gateway.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-auth-dev"
      repo_url         = "https://github.com/example-org/team9-backend-auth.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-user-dev"
      repo_url         = "https://github.com/example-org/team9-backend-user.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-chat-dev"
      repo_url         = "https://github.com/example-org/team9-backend-chat.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-notification-dev"
      repo_url         = "https://github.com/example-org/team9-backend-notification.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-media-dev"
      repo_url         = "https://github.com/example-org/team9-backend-media.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
    {
      job_name         = "backend-admin-dev"
      repo_url         = "https://github.com/example-org/team9-backend-admin.git"
      branch           = "main"
      jenkinsfile_path = "Jenkinsfile"
    },
  ]
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-terraform-state-dev"
}

variable "terraform_state_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "platform_state_key" {
  type    = string
  default = "04-platform-eks/terraform.tfstate"
}
