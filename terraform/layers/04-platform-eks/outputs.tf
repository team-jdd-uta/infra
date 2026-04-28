output "cluster_name" {
  value = module.platform_eks.cluster_name
}

output "cluster_endpoint" {
  value = module.platform_eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value     = module.platform_eks.cluster_ca_certificate
  sensitive = true
}

output "cluster_security_group_id" {
  value = module.platform_eks.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.platform_eks.node_security_group_id
}

output "oidc_provider_arn" {
  value = module.platform_eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  value = module.platform_eks.oidc_issuer_url
}
