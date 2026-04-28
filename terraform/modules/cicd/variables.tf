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

variable "harbor_registry_url" {
  type = string
}

variable "harbor_robot_secret_name" {
  type = string
}
