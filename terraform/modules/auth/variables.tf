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

variable "login_service_namespace" {
  type    = string
  default = "backend"
}

variable "login_service_service_account_name" {
  type    = string
  default = "backend-login-service"
}

variable "cognito_password_minimum_length" {
  type    = number
  default = 8
}
