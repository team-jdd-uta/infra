locals {
  oidc_issuer_url = replace(var.oidc_issuer_url, "https://", "")

  enabled_components = {
    jenkins_controller = true
    ephemeral_agents   = true
    ecr                = true
    jcasc              = true
    job_dsl            = true
  }

  ecr_repository_names = distinct(concat(var.ecr_backend_repository_names, var.ecr_legacy_repository_names))

  pipeline_webhook_repositories = toset(distinct(concat(
    [trimsuffix(basename(var.frontend_pipeline_repo_url), ".git")],
    [for repo in var.backend_pipeline_repositories : trimsuffix(basename(repo.repo_url), ".git")]
  )))

  jcasc_config = templatefile("${path.module}/assets/jenkins/jcasc.yaml.tftpl", {
    jenkins_git_credentials_id           = var.jenkins_git_credentials_id
    jenkins_git_username_secret_value    = format("$${%s-git-username}", var.jenkins_git_k8s_secret_name)
    jenkins_git_token_secret_value       = format("$${%s-git-token}", var.jenkins_git_k8s_secret_name)
    jenkins_slack_webhook_credentials_id = var.jenkins_slack_webhook_credentials_id
    jenkins_slack_webhook_secret_value   = format("$${%s-webhook-url}", var.jenkins_slack_webhook_k8s_secret_name)
    jenkins_admin_username_secret_value  = format("$${%s-chart-admin-username}", var.jenkins_admin_k8s_secret_name)
    jenkins_admin_password_secret_value  = format("$${%s-chart-admin-password}", var.jenkins_admin_k8s_secret_name)
    jenkins_namespace                    = "jenkins"
    jenkins_url                          = "http://jenkins.jenkins.svc.cluster.local:8080"
    jenkins_public_url                   = var.jenkins_public_url
    jenkins_tunnel                       = "jenkins-agent.jenkins.svc.cluster.local:50000"
    jenkins_agent_service_account        = var.jenkins_kaniko_service_account_name
  })

  seed_job_script = templatefile("${path.module}/assets/jenkins/jobs/seed.groovy.tftpl", {
    frontend_pipeline_job_name         = var.frontend_pipeline_job_name
    frontend_pipeline_repo_url         = var.frontend_pipeline_repo_url
    frontend_pipeline_repo_branch      = var.frontend_pipeline_repo_branch
    frontend_pipeline_jenkinsfile_path = var.frontend_pipeline_jenkinsfile_path
    jenkins_git_credentials_id         = var.jenkins_git_credentials_id
    backend_pipeline_repositories      = var.backend_pipeline_repositories
  })

  cleanup_obsolete_jobs_script = <<-GROOVY
    import jenkins.model.Jenkins

    def obsoleteJobs = ${jsonencode(var.jenkins_obsolete_job_names)}
    def instance = Jenkins.get()

    obsoleteJobs.each { jobName ->
      def item = instance.getItemByFullName(jobName)
      if (item != null) {
        println("Deleting obsolete Jenkins job '$${jobName}'")
        item.delete()
      }
    }

    instance.save()
  GROOVY
}

resource "aws_ecr_repository" "repositories" {
  for_each = toset(local.ecr_repository_names)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = aws_ecr_repository.repositories

  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the most recent 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "github_repository_webhook" "jenkins" {
  for_each = local.pipeline_webhook_repositories

  repository = each.value

  configuration {
    url          = var.github_webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true
  events = ["push"]
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

data "aws_iam_policy_document" "jenkins_kaniko_assume_role" {
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
      values   = ["system:serviceaccount:${kubernetes_namespace.jenkins.metadata[0].name}:${var.jenkins_kaniko_service_account_name}"]
    }
  }
}

data "aws_iam_policy_document" "jenkins_kaniko_ecr_push" {
  statement {
    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [for repository in aws_ecr_repository.repositories : repository.arn]
  }
}

data "aws_iam_policy_document" "jenkins_frontend_deploy" {
  statement {
    sid       = "FrontendBucketList"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.frontend_bucket_name}"]
  }

  statement {
    sid = "FrontendBucketObjects"
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${var.frontend_bucket_name}/*"]
  }

  statement {
    sid       = "CloudFrontInvalidation"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "jenkins_kaniko_agent" {
  name               = "${var.project_name}-${var.environment}-jenkins-kaniko-agent"
  assume_role_policy = data.aws_iam_policy_document.jenkins_kaniko_assume_role.json
}

resource "aws_iam_policy" "jenkins_kaniko_ecr_push" {
  name   = "${var.project_name}-${var.environment}-jenkins-kaniko-ecr-push"
  policy = data.aws_iam_policy_document.jenkins_kaniko_ecr_push.json
}

resource "aws_iam_role_policy_attachment" "jenkins_kaniko_ecr_push" {
  role       = aws_iam_role.jenkins_kaniko_agent.name
  policy_arn = aws_iam_policy.jenkins_kaniko_ecr_push.arn
}

resource "aws_iam_role_policy" "jenkins_frontend_deploy" {
  name   = "${var.project_name}-${var.environment}-frontend-s3-cloudfront-policy"
  role   = aws_iam_role.jenkins_kaniko_agent.id
  policy = data.aws_iam_policy_document.jenkins_frontend_deploy.json
}

resource "kubernetes_service_account" "jenkins_kaniko_agent" {
  metadata {
    name      = var.jenkins_kaniko_service_account_name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_agent.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.jenkins_frontend_deploy,
    aws_iam_role_policy_attachment.jenkins_kaniko_ecr_push,
  ]
}

resource "kubernetes_manifest" "jenkins_admin_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "jenkins-admin"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.external_secrets_cluster_secret_store_name
      }
      target = {
        name           = var.jenkins_admin_k8s_secret_name
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "chart-admin-username"
          remoteRef = {
            key      = var.jenkins_admin_secret_name
            property = "username"
          }
        },
        {
          secretKey = "chart-admin-password"
          remoteRef = {
            key      = var.jenkins_admin_secret_name
            property = "password"
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "jenkins_git_credentials_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "jenkins-git-credentials"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.external_secrets_cluster_secret_store_name
      }
      target = {
        name           = var.jenkins_git_k8s_secret_name
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "git-username"
          remoteRef = {
            key      = var.jenkins_git_credentials_secret_name
            property = "username"
          }
        },
        {
          secretKey = "git-token"
          remoteRef = {
            key      = var.jenkins_git_credentials_secret_name
            property = "token"
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "jenkins_slack_webhook_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "jenkins-slack-webhook"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.external_secrets_cluster_secret_store_name
      }
      target = {
        name           = var.jenkins_slack_webhook_k8s_secret_name
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "webhook-url"
          remoteRef = {
            key      = var.slack_webhook_secret_name
            property = "url"
          }
        },
      ]
    }
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    yamlencode({
      controller = {
        admin = {
          createSecret   = false
          existingSecret = var.jenkins_admin_k8s_secret_name
        }
        installPlugins = [
          "kubernetes",
          "workflow-aggregator",
          "git",
          "github",
          "configuration-as-code",
          "job-dsl",
          "credentials",
          "credentials-binding",
          "plain-credentials",
          "timestamper",
        ]
        initScripts = {
          "delete-obsolete-generated-jobs" = local.cleanup_obsolete_jobs_script
        }
        JCasC = {
          defaultConfig = false
          configScripts = {
            "01-security-and-credentials" = local.jcasc_config
            "02-seed-jobs"                = local.seed_job_script
          }
        }
        additionalExistingSecrets = [
          {
            name    = var.jenkins_admin_k8s_secret_name
            keyName = "chart-admin-username"
          },
          {
            name    = var.jenkins_admin_k8s_secret_name
            keyName = "chart-admin-password"
          },
          {
            name    = var.jenkins_git_k8s_secret_name
            keyName = "git-username"
          },
          {
            name    = var.jenkins_git_k8s_secret_name
            keyName = "git-token"
          },
          {
            name    = var.jenkins_slack_webhook_k8s_secret_name
            keyName = "webhook-url"
          }
        ]
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          hostName         = var.jenkins_hostname
          annotations = {
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"     = "ip"
            "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
            "alb.ingress.kubernetes.io/certificate-arn" = var.ingress_certificate_arn
            "external-dns.alpha.kubernetes.io/hostname" = var.jenkins_hostname
          }
        }
      }
      agent = {
        enabled       = true
        namespace     = kubernetes_namespace.jenkins.metadata[0].name
        jenkinsUrl    = "http://jenkins.${kubernetes_namespace.jenkins.metadata[0].name}.svc.cluster.local:8080"
        jenkinsTunnel = "jenkins-agent.${kubernetes_namespace.jenkins.metadata[0].name}.svc.cluster.local:50000"
      }
      persistence = {
        enabled      = true
        size         = "20Gi"
        storageClass = "gp2"
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.jenkins_admin_external_secret,
    kubernetes_manifest.jenkins_git_credentials_external_secret,
    kubernetes_manifest.jenkins_slack_webhook_external_secret,
  ]
}
