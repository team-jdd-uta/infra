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
    "team9-kafka-outbox",
    "team9-user-service",
    "team9-redis-stream-mongo-consumer",
    "team9-login-service",
    "team9-socket-io-gateway",
    "team9-chat-service",
    "team9-room-service",
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

variable "external_secrets_cluster_secret_store_name" {
  type    = string
  default = "aws-secretsmanager"
}

variable "frontend_pipeline_job_name" {
  type    = string
  default = "frontend-dev"
}

variable "jenkins_hostname" {
  type    = string
  default = "jenkins.team9.cloud.skala-ai.com"
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
      job_name         = "backend-kafka-outbox-dev"
      repo_url         = "https://github.com/team-jdd-uta/backend-kafka-outbox"
      branch           = "main"
      jenkinsfile_path = "jenkins/Jenkinsfile"
    },
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
