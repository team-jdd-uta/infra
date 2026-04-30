locals {
  enabled_components = {
    jenkins_controller = true
    ephemeral_agents   = true
    ecr                = true
    jcasc              = true
    job_dsl            = true
  }

  ecr_repository_names = concat(
    [var.ecr_frontend_repository_name],
    var.ecr_backend_repository_names
  )

  jcasc_config = templatefile("${path.module}/assets/jenkins/jcasc.yaml.tftpl", {
    jenkins_admin_username     = var.jenkins_admin_username
    jenkins_admin_password     = var.jenkins_admin_password
    jenkins_git_credentials_id = var.jenkins_git_credentials_id
    jenkins_git_username       = var.jenkins_git_username
    jenkins_git_token          = var.jenkins_git_token
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

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    yamlencode({
      controller = {
        admin = {
          username = var.jenkins_admin_username
          password = var.jenkins_admin_password
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
          configScripts = {
            "01-security-and-credentials" = local.jcasc_config
            "02-seed-jobs"                = local.seed_job_script
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
}
