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

variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "root_domain_name" {
  type = string
}

variable "cert_manager_email" {
  type = string
}

variable "argocd_hostname" {
  type = string
}

variable "ingress_certificate_arn" {
  type = string
}

variable "slack_webhook_secret_name" {
  type = string
}

variable "external_secrets_cluster_secret_store_name" {
  type = string
}
