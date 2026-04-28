output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  value = aws_subnet.private_data[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "kms_key_arn" {
  value = aws_kms_key.infra.arn
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "availability_zones" {
  value = local.azs
}
