output "cicd_summary" {
  value = {
    enabled_components = local.enabled_components
    jenkins_url        = "https://${var.jenkins_hostname}"
    kaniko_service_account = {
      name     = kubernetes_service_account.jenkins_kaniko_agent.metadata[0].name
      role_arn = aws_iam_role.jenkins_kaniko_agent.arn
    }
    ecr_repository_urls = {
      for name, repo in aws_ecr_repository.repositories : name => repo.repository_url
    }
  }
}
