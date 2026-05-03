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

variable "ecr_backend_repository_names" {
  type = list(string)
  default = [
    "team9-user-service",
    "team9-redis-stream-mongo-consumer",
    "team9-login-service",
    "team9-socket-io-gateway",
    "team9-chat-service",
    "team9-room-service",
    "team9-ai-chat-summary",
    "team9-rtmp",
  ]
}

variable "ecr_legacy_repository_names" {
  type = list(string)
  default = [
    "team9-ui-vue",
    "team9-debezium-connect",
  ]
}

variable "jenkins_git_credentials_id" {
  type    = string
  default = "gitops-scm-creds"
}

variable "jenkins_admin_secret_name" {
  type    = string
  default = "team9-mini/dev/jenkins/admin"
}

variable "jenkins_admin_k8s_secret_name" {
  type    = string
  default = "jenkins-admin-credentials"
}

variable "jenkins_git_credentials_secret_name" {
  type    = string
  default = "team9-mini/dev/jenkins/git-credentials"
}

variable "jenkins_git_k8s_secret_name" {
  type    = string
  default = "jenkins-git-credentials"
}

variable "slack_webhook_secret_name" {
  type    = string
  default = "team9-mini/slack/webhook"
}

variable "jenkins_slack_webhook_k8s_secret_name" {
  type    = string
  default = "jenkins-slack-webhook"
}

variable "jenkins_slack_webhook_credentials_id" {
  type    = string
  default = "jenkins-slack-webhook"
}

variable "external_secrets_cluster_secret_store_name" {
  type    = string
  default = "aws-secretsmanager"
}

variable "frontend_pipeline_job_name" {
  type    = string
  default = "frontend-dev"
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or user that owns the pipeline repositories."
  default     = "team-jdd-uta"
}

variable "github_webhook_url" {
  type        = string
  description = "Jenkins GitHub webhook endpoint registered on pipeline repositories."
  default     = "https://jenkins.team9.cloud.skala-ai.com/github-webhook/"
}

variable "jenkins_hostname" {
  type    = string
  default = "jenkins.team9.cloud.skala-ai.com"
}

variable "jenkins_public_url" {
  type    = string
  default = "https://jenkins.team9.cloud.skala-ai.com"
}

variable "frontend_pipeline_repo_url" {
  type    = string
  default = "https://github.com/team-jdd-uta/frontend-ui-vue.git"
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
      job_name         = "backend-user-service-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-user-service.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-redis-stream-mongo-consumer-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-redis-stream-mongo-consumer.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-login-service-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-login-service.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-socket-io-gateway-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-socket-io-gateway.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-chat-service-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-chat-service.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-room-service-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-room-service.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "ai-chat-summary-dev"
      repo_url         = "https://github.com/team-jdd-uta/AI-chat-summery.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
    {
      job_name         = "backend-rtmp-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-rtmp.git"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
  ]
}

variable "terraform_state_bucket" {
  type    = string
  default = "team9-mini-dev-terraform-state"
}

variable "terraform_state_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "platform_state_key" {
  type    = string
  default = "04-platform-eks/terraform.tfstate"
}

variable "edge_state_key" {
  type    = string
  default = "03-edge/terraform.tfstate"
}

variable "jenkins_kaniko_service_account_name" {
  type    = string
  default = "jenkins-kaniko-agent"
}

variable "frontend_bucket_name" {
  type        = string
  description = "S3 bucket name used by the frontend deployment pipeline."
  default     = "team9-mini-dev-frontend"
}

variable "jenkins_obsolete_job_names" {
  type        = list(string)
  description = "Previously generated Jenkins jobs to delete during controller startup."
  default = [
    "backend-kafka-outbox-dev",
    "chat-service-dev",
    "debezium-connect-dev",
    "login-service-dev",
    "redis-stream-mongo-consumer-dev",
    "room-service-dev",
    "socket-io-gateway-dev",
    "user-service-dev",
  ]
}
