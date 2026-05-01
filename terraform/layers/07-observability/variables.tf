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

variable "slack_webhook_secret_name" {
  type    = string
  default = "team9-mini/slack/webhook"
}

variable "slack_alert_channel" {
  type    = string
  default = "#team9-alerts"
}

variable "slack_webhook_k8s_secret_name" {
  type    = string
  default = "alertmanager-slack-webhook"
}

variable "external_secrets_cluster_secret_store_name" {
  type    = string
  default = "aws-secretsmanager"
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

variable "grafana_hostname" {
  type    = string
  default = "grafana.team9.cloud.skala-ai.com"
}
