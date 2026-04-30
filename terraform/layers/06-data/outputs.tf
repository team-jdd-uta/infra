output "rds_instance_identifiers" {
  value = module.data.rds_instance_identifiers
}

output "msk_cluster_arn" {
  value = module.data.msk_cluster_arn
}

output "msk_cluster_name" {
  value = module.data.msk_cluster_name
}

output "msk_bootstrap_brokers_sasl_iam" {
  value = module.data.msk_bootstrap_brokers_sasl_iam
}

output "documentdb_cluster_id" {
  value = module.data.documentdb_cluster_id
}
