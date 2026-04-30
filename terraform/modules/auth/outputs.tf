output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.web.id
}

output "login_service_role_arn" {
  value = aws_iam_role.login_service.arn
}

output "login_service_service_account_subject" {
  value = "system:serviceaccount:${var.login_service_namespace}:${var.login_service_service_account_name}"
}
