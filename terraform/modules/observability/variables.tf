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

variable "slack_webhook_secret_name" {
  type = string
}

variable "slack_alert_channel" {
  type = string
}

variable "slack_webhook_k8s_secret_name" {
  type = string
}

variable "external_secrets_cluster_secret_store_name" {
  type = string
}

variable "grafana_hostname" {
  type = string
}

variable "ingress_certificate_arn" {
  type = string
}
