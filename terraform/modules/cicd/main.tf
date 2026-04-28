locals {
  enabled_components = {
    jenkins_controller = true
    ephemeral_agents   = true
    external_harbor    = true
  }
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
        installPlugins = [
          "kubernetes",
          "workflow-aggregator",
          "git",
          "configuration-as-code",
        ]
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
