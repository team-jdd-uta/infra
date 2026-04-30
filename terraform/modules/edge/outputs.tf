output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_certificate_arn" {
  value = aws_acm_certificate_validation.frontend.certificate_arn
}

output "alb_ingress_certificate_arn" {
  value = aws_acm_certificate_validation.alb_ingress.certificate_arn
}
