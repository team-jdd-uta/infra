output "addons_summary" {
  value = module.platform_addons.addons_summary
}

output "external_dns_role_arn" {
  value = module.platform_addons.external_dns_role_arn
}

output "external_secrets_role_arn" {
  value = module.platform_addons.external_secrets_role_arn
}

output "cluster_secret_store_name" {
  value = module.platform_addons.cluster_secret_store_name
}

output "argocd_url" {
  value = module.platform_addons.argocd_url
}
