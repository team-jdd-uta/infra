output "frontend_bucket_name" {
  value = module.edge.frontend_bucket_name
}

output "cloudfront_distribution_id" {
  value = module.edge.cloudfront_distribution_id
}

output "alb_ingress_certificate_arn" {
  value = module.edge.alb_ingress_certificate_arn
}
