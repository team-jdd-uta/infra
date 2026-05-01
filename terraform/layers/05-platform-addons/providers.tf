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

data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.foundation_state_key
    region = var.terraform_state_region
  }
}

data "terraform_remote_state" "edge" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.edge_state_key
    region = var.terraform_state_region
  }
}

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.platform.outputs.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
