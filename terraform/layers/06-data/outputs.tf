output "rds_instance_identifiers" {
  value = module.data.rds_instance_identifiers
}

output "redis_replication_group_id" {
  value = module.data.redis_replication_group_id
}

output "documentdb_cluster_id" {
  value = module.data.documentdb_cluster_id
}
