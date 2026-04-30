output "cognito_user_pool_id" {
  value = module.auth.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.auth.cognito_user_pool_client_id
}

output "login_service_role_arn" {
  value = module.auth.login_service_role_arn
}

output "login_service_service_account_subject" {
  value = module.auth.login_service_service_account_subject
}
