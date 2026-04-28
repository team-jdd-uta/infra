output "state_bucket_name" {
  description = "Terraform state bucket name."
  value       = module.bootstrap_backend.state_bucket_name
}

output "lock_table_name" {
  description = "Terraform lock table name."
  value       = module.bootstrap_backend.lock_table_name
}
