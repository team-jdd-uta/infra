locals {
  name_prefix     = "${var.project_name}-${var.environment}"
  oidc_issuer_url = replace(var.oidc_issuer_url, "https://", "")
}

resource "aws_cognito_user_pool" "this" {
  name = "${local.name_prefix}-users"

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = var.cognito_password_minimum_length
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name         = "${local.name_prefix}-web-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  ]

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"
}

data "aws_iam_policy_document" "login_service_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.login_service_namespace}:${var.login_service_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "login_service" {
  name               = "${local.name_prefix}-login-service-cognito"
  assume_role_policy = data.aws_iam_policy_document.login_service_assume_role.json
}

data "aws_iam_policy_document" "login_service_cognito" {
  statement {
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminSetUserPassword",
    ]
    resources = [aws_cognito_user_pool.this.arn]
  }
}

resource "aws_iam_policy" "login_service_cognito" {
  name   = "${local.name_prefix}-login-service-cognito"
  policy = data.aws_iam_policy_document.login_service_cognito.json
}

resource "aws_iam_role_policy_attachment" "login_service_cognito" {
  role       = aws_iam_role.login_service.name
  policy_arn = aws_iam_policy.login_service_cognito.arn
}
