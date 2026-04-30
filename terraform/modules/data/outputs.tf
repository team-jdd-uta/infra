output "rds_instance_identifiers" {
  value = { for service, instance in aws_db_instance.mariadb : service => instance.identifier }
}

output "rds_instance_endpoints" {
  value = { for service, instance in aws_db_instance.mariadb : service => instance.address }
}

output "rds_credentials_secret_names" {
  value = { for service, secret in aws_secretsmanager_secret.rds : service => secret.name }
}

output "msk_cluster_arn" {
  value = aws_msk_cluster.this.arn
}

output "msk_cluster_name" {
  value = aws_msk_cluster.this.cluster_name
}

output "msk_bootstrap_brokers_sasl_iam" {
  value = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
}

output "documentdb_cluster_id" {
  value = aws_docdb_cluster.this.cluster_identifier
}

output "debezium_connector_arn" {
  value = try(aws_mskconnect_connector.debezium_source["user-service"].arn, null)
}

output "debezium_connector_arns" {
  value = { for service, connector in aws_mskconnect_connector.debezium_source : service => connector.arn }
}

output "debezium_connector_names" {
  value = { for service, connector in aws_mskconnect_connector.debezium_source : service => connector.name }
}
