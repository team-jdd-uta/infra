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

variable "root_domain_name" {
  type    = string
  default = "example.com"
}

variable "frontend_domain_name" {
  type    = string
  default = "app.example.com"
}

variable "ingress_wildcard_domain_name" {
  type    = string
  default = "*.example.com"
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
}
