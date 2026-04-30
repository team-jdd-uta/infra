output "addons_summary" {
  value = local.addons
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}

output "cluster_secret_store_name" {
  value = kubernetes_manifest.external_secrets_cluster_secret_store.manifest.metadata.name
}

output "argocd_url" {
  value = "https://${var.argocd_hostname}"
}
