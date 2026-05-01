locals {
  enabled_components = [
    "cloudwatch",
    "prometheus",
    "loki",
    "grafana",
    "slack-alerting",
  ]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_manifest" "alertmanager_slack_webhook_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "alertmanager-slack-webhook"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.external_secrets_cluster_secret_store_name
      }
      target = {
        name           = var.slack_webhook_k8s_secret_name
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "webhook_url"
          remoteRef = {
            key      = var.slack_webhook_secret_name
            property = "url"
          }
        },
      ]
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      defaultRules = {
        rules = {
          kubeControllerManager = false
          kubeSchedulerAlerting = false
          kubeSchedulerRecording = false
        }
      }
      kubeControllerManager = {
        enabled = false
      }
      kubeScheduler = {
        enabled = false
      }
      grafana = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          hosts            = [var.grafana_hostname]
          path             = "/"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"     = "ip"
            "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
            "alb.ingress.kubernetes.io/certificate-arn" = var.ingress_certificate_arn
            "alb.ingress.kubernetes.io/success-codes"   = "200-399"
            "external-dns.alpha.kubernetes.io/hostname" = var.grafana_hostname
          }
        }
        "grafana.ini" = {
          server = {
            root_url = "https://${var.grafana_hostname}"
          }
        }
      }
      alertmanager = {
        config = {
          global = {
            resolve_timeout    = "5m"
            slack_api_url_file = "/etc/alertmanager/secrets/${var.slack_webhook_k8s_secret_name}/webhook_url"
          }
          inhibit_rules = [
            {
              source_matchers = ["severity = critical"]
              target_matchers = ["severity =~ warning|info"]
              equal           = ["namespace", "alertname"]
            },
            {
              source_matchers = ["severity = warning"]
              target_matchers = ["severity = info"]
              equal           = ["namespace", "alertname"]
            },
            {
              source_matchers = ["alertname = InfoInhibitor"]
              target_matchers = ["severity = info"]
              equal           = ["namespace"]
            },
            {
              target_matchers = ["alertname = InfoInhibitor"]
            },
          ]
          route = {
            group_by        = ["namespace", "alertname"]
            group_wait      = "30s"
            group_interval  = "5m"
            repeat_interval = "6h"
            receiver        = "slack-alerts"
            routes = [
              {
                receiver = "null"
                matchers = ["alertname = Watchdog"]
              },
              {
                receiver        = "slack-critical"
                matchers        = ["severity = critical"]
                repeat_interval = "1h"
              },
            ]
          }
          receivers = [
            {
              name = "null"
            },
            {
              name = "slack-alerts"
              slack_configs = [
                {
                  channel       = var.slack_alert_channel
                  color         = "{{ if eq .Status \"resolved\" }}#2f80ed{{ else if eq .CommonLabels.severity \"critical\" }}danger{{ else }}warning{{ end }}"
                  send_resolved = true
                  title         = "{{ if eq .Status \"resolved\" }}🔵 [해결]{{ else if eq .CommonLabels.severity \"critical\" }}🔴 [발생]{{ else }}🟡 [발생]{{ end }} {{ if .CommonLabels.service }}{{ .CommonLabels.service }}{{ else }}Kubernetes{{ end }} - {{ .CommonLabels.alertname }}"
                  text          = <<-EOT
                    {{ range .Alerts }}
                    *서비스:* {{ if .Labels.service }}{{ .Labels.service }}{{ else }}Kubernetes{{ end }}
                    *심각도:* {{ .Labels.severity }}
                    *환경:* ${var.environment}
                    *네임스페이스:* {{ if .Labels.namespace }}{{ .Labels.namespace }}{{ else }}-{{ end }}
                    *대상:* {{ if .Labels.pod }}{{ .Labels.pod }}{{ else if .Labels.instance }}{{ .Labels.instance }}{{ else }}-{{ end }}
                    *상태:* {{ if eq .Status "firing" }}발생{{ else }}해결{{ end }}
                    *요약:* {{ .Annotations.summary }}
                    *설명:* {{ .Annotations.description }}
                    {{ end }}
                  EOT
                },
              ]
            },
            {
              name = "slack-critical"
              slack_configs = [
                {
                  channel       = var.slack_alert_channel
                  color         = "{{ if eq .Status \"resolved\" }}#2f80ed{{ else }}danger{{ end }}"
                  send_resolved = true
                  title         = "<!channel> {{ if eq .Status \"resolved\" }}🔵 [해결]{{ else }}🔴 [발생]{{ end }} {{ if .CommonLabels.service }}{{ .CommonLabels.service }}{{ else }}Kubernetes{{ end }} - {{ .CommonLabels.alertname }}"
                  text          = <<-EOT
                    {{ range .Alerts }}
                    *서비스:* {{ if .Labels.service }}{{ .Labels.service }}{{ else }}Kubernetes{{ end }}
                    *심각도:* {{ .Labels.severity }}
                    *환경:* ${var.environment}
                    *네임스페이스:* {{ if .Labels.namespace }}{{ .Labels.namespace }}{{ else }}-{{ end }}
                    *대상:* {{ if .Labels.pod }}{{ .Labels.pod }}{{ else if .Labels.instance }}{{ .Labels.instance }}{{ else }}-{{ end }}
                    *상태:* {{ if eq .Status "firing" }}발생{{ else }}해결{{ end }}
                    *요약:* {{ .Annotations.summary }}
                    *설명:* {{ .Annotations.description }}
                    {{ end }}
                  EOT
                },
              ]
            },
          ]
          templates = ["/etc/alertmanager/config/*.tmpl"]
        }
        alertmanagerSpec = {
          secrets = [var.slack_webhook_k8s_secret_name]
        }
      }
      additionalPrometheusRulesMap = {
        team9-grafana-alerts = {
          groups = [
            {
              name = "team9.grafana.rules"
              rules = [
                {
                  alert = "GrafanaP95LatencyHigh"
                  expr  = "histogram_quantile(0.95, sum by (le) (rate(grafana_http_request_duration_seconds_bucket{namespace=\"monitoring\"}[5m]))) > 1"
                  for   = "5m"
                  labels = {
                    severity = "warning"
                    service  = "Grafana"
                  }
                  annotations = {
                    summary     = "Grafana p95 latency가 1초를 초과했습니다."
                    description = "최근 5분 기준 Grafana HTTP 요청 p95 latency가 1초를 초과했습니다. Grafana 대시보드 또는 데이터소스 응답 지연을 확인하세요."
                  }
                },
                {
                  alert = "GrafanaCpuLimitUsageHigh"
                  expr  = "sum by (namespace, pod) (rate(container_cpu_usage_seconds_total{namespace=\"monitoring\",pod=~\"kube-prometheus-stack-grafana-.*\",container!=\"\",image!=\"\"}[5m])) / sum by (namespace, pod) (kube_pod_container_resource_limits{namespace=\"monitoring\",pod=~\"kube-prometheus-stack-grafana-.*\",resource=\"cpu\",unit=\"core\"}) > 0.5"
                  for   = "10m"
                  labels = {
                    severity = "warning"
                    service  = "Grafana"
                  }
                  annotations = {
                    summary     = "Grafana CPU 사용률이 limit 대비 50%를 초과했습니다."
                    description = "최근 10분 동안 Grafana pod CPU 사용률이 설정된 CPU limit의 50%를 초과했습니다. 대시보드 쿼리 부하와 데이터소스 상태를 확인하세요."
                  }
                },
              ]
            },
          ]
        }
      }
    })
  ]

  depends_on = [kubernetes_manifest.alertmanager_slack_webhook_external_secret]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
        schemaConfig = {
          configs = [
            {
              from         = "2024-01-01"
              store        = "tsdb"
              object_store = "filesystem"
              schema       = "v13"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }
      }
      singleBinary = {
        persistence = {
          enabled      = true
          size         = "5Gi"
          storageClass = "gp2"
        }
        replicas = 1
      }
      backend = {
        replicas = 0
      }
      read = {
        replicas = 0
      }
      write = {
        replicas = 0
      }
      gateway = {
        enabled = false
      }
      chunksCache = {
        enabled = false
      }
      resultsCache = {
        enabled = false
      }
      lokiCanary = {
        enabled = false
      }
      test = {
        enabled = false
      }
    })
  ]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}
