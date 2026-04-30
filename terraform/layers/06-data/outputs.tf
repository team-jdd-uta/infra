output "rds_instance_identifiers" {
  value = module.data.rds_instance_identifiers
}

output "rds_instance_endpoints" {
  value = module.data.rds_instance_endpoints
}

output "rds_credentials_secret_names" {
  value = module.data.rds_credentials_secret_names
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

output "debezium_connector_arns" {
  value = module.data.debezium_connector_arns
}

output "debezium_connector_names" {
  value = module.data.debezium_connector_names
}
