output "vpc_id" {
  value = module.foundation.vpc_id
}

output "private_app_subnet_ids" {
  value = module.foundation.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.foundation.private_data_subnet_ids
}

output "public_subnet_ids" {
  value = module.foundation.public_subnet_ids
}

output "kms_key_arn" {
  value = module.foundation.kms_key_arn
}

output "vpc_cidr" {
  value = module.foundation.vpc_cidr
}
