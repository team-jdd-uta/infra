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

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "ecr_backend_repository_names" {
  type = list(string)
}

variable "ecr_legacy_repository_names" {
  type = list(string)
}

variable "jenkins_git_credentials_id" {
  type = string
}

variable "jenkins_admin_secret_name" {
  type = string
}

variable "jenkins_admin_k8s_secret_name" {
  type = string
}

variable "jenkins_git_credentials_secret_name" {
  type = string
}

variable "jenkins_git_k8s_secret_name" {
  type = string
}

variable "external_secrets_cluster_secret_store_name" {
  type = string
}

variable "frontend_pipeline_job_name" {
  type = string
}

variable "jenkins_hostname" {
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

variable "jenkins_kaniko_service_account_name" {
  type    = string
  default = "jenkins-kaniko-agent"
}

variable "frontend_bucket_name" {
  type        = string
  description = "S3 bucket name used by the frontend deployment pipeline."
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
