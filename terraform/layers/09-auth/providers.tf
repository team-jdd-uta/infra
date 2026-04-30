provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.platform_state_key
    region = var.terraform_state_region
  }
}
