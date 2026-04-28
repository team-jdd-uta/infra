output "rds_instance_identifiers" {
  value = aws_db_instance.mariadb[*].identifier
}

output "redis_replication_group_id" {
  value = aws_elasticache_replication_group.redis.replication_group_id
}

output "documentdb_cluster_id" {
  value = aws_docdb_cluster.this.cluster_identifier
}
