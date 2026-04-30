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

variable "root_domain_name" {
  type = string
}

variable "frontend_domain_name" {
  type = string
}

variable "ingress_wildcard_domain_name" {
  description = "Wildcard domain name used for ALB-backed Kubernetes ingress certificates."
  type        = string
}

variable "price_class" {
  type = string
}
