output "rds_instance_identifiers" {
  value = aws_db_instance.mariadb[*].identifier
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
