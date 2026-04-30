output "cicd_summary" {
  value = {
    enabled_components = local.enabled_components
    ecr_repository_urls = {
      for name, repo in aws_ecr_repository.repositories : name => repo.repository_url
    }
  }
}
