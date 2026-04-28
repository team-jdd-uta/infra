module "foundation" {
  source = "../../modules/foundation"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  common_tags        = var.common_tags
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  nat_gateway_per_az = var.nat_gateway_per_az
  cluster_tag        = "${var.project_name}-${var.environment}-eks"
}
