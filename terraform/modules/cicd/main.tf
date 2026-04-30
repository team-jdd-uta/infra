locals {
  enabled_components = {
    jenkins_controller = true
    ephemeral_agents   = true
    ecr                = true
    jcasc              = true
    job_dsl            = true
  }

  ecr_repository_names = var.ecr_backend_repository_names

  jcasc_config = templatefile("${path.module}/assets/jenkins/jcasc.yaml.tftpl", {
    jenkins_git_credentials_id        = var.jenkins_git_credentials_id
    jenkins_git_username_secret_value = format("$${%s-git-username}", var.jenkins_git_k8s_secret_name)
    jenkins_git_token_secret_value    = format("$${%s-git-token}", var.jenkins_git_k8s_secret_name)
  })

  seed_job_script = templatefile("${path.module}/assets/jenkins/jobs/seed.groovy.tftpl", {
    frontend_pipeline_job_name         = var.frontend_pipeline_job_name
    frontend_pipeline_repo_url         = var.frontend_pipeline_repo_url
    frontend_pipeline_repo_branch      = var.frontend_pipeline_repo_branch
    frontend_pipeline_jenkinsfile_path = var.frontend_pipeline_jenkinsfile_path
    jenkins_git_credentials_id         = var.jenkins_git_credentials_id
    backend_pipeline_repositories      = var.backend_pipeline_repositories
  })
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

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
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
          secretKey = "jenkins-admin-user"
          remoteRef = {
            key      = var.jenkins_admin_secret_name
            property = "username"
          }
        },
        {
          secretKey = "jenkins-admin-password"
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
          "configuration-as-code",
          "job-dsl",
          "credentials",
          "plain-credentials",
        ]
        JCasC = {
          defaultConfig = false
          configScripts = {
            "01-security-and-credentials" = local.jcasc_config
            "02-seed-jobs"                = local.seed_job_script
          }
        }
        additionalExistingSecrets = [
          {
            name    = var.jenkins_git_k8s_secret_name
            keyName = "git-username"
          },
          {
            name    = var.jenkins_git_k8s_secret_name
            keyName = "git-token"
          }
        ]
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          hostName         = var.jenkins_hostname
          annotations = {
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "external-dns.alpha.kubernetes.io/hostname" = var.jenkins_hostname
          }
        }
      }
      agent = {
        enabled = true
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
  ]
}
