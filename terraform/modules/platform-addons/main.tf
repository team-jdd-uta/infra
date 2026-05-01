locals {
  addons = {
    metrics_server               = true
    external_secrets             = true
    cert_manager                 = true
    aws_load_balancer_controller = true
    external_dns                 = true
    argo_cd                      = true
  }
}

data "aws_iam_policy_document" "alb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cert_manager_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "alb_controller" {
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:Describe*",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "cognito-idp:DescribeUserPoolClient",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions = [
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByName",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.project_name}-${var.environment}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.project_name}-${var.environment}-alb-controller-policy"
  policy = data.aws_iam_policy_document.alb_controller.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "aws_iam_role" "external_dns" {
  name               = "${var.project_name}-${var.environment}-external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
}

resource "aws_iam_policy" "external_dns" {
  name   = "${var.project_name}-${var.environment}-external-dns-policy"
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_role" "cert_manager" {
  name               = "${var.project_name}-${var.environment}-cert-manager-role"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.project_name}-${var.environment}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json
}

resource "aws_iam_policy" "cert_manager" {
  name   = "${var.project_name}-${var.environment}-cert-manager-policy"
  policy = data.aws_iam_policy_document.cert_manager.json
}

resource "aws_iam_policy" "external_secrets" {
  name   = "${var.project_name}-${var.environment}-external-secrets-policy"
  policy = data.aws_iam_policy_document.external_secrets.json
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = var.vpc_id
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
        }
      }
    })
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"

  values = [
    yamlencode({
      provider      = "aws"
      domainFilters = [var.root_domain_name]
      serviceAccount = {
        create = true
        name   = "external-dns"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
        }
      }
    })
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-secrets"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "external_secrets_cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secretsmanager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = kubernetes_namespace.external_secrets.metadata[0].name
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      serviceAccount = {
        create = true
        name   = "cert-manager"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager.arn
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = var.cert_manager_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = var.aws_region
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "argocd_notifications_slack_webhook_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "argocd-notifications-slack-webhook"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.external_secrets_cluster_secret_store_name
      }
      target = {
        name           = "argocd-notifications-secret"
        creationPolicy = "Merge"
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

  depends_on = [kubernetes_manifest.external_secrets_cluster_secret_store]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        domain = var.argocd_hostname
      }
      server = {
        extraArgs = ["--insecure"]
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          hostname         = var.argocd_hostname
          annotations = {
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"     = "ip"
            "external-dns.alpha.kubernetes.io/hostname" = var.argocd_hostname
          }
        }
      }
      notifications = {
        enabled   = true
        argocdUrl = "https://${var.argocd_hostname}"
        notifiers = {
          "service.webhook.slack_webhook" = <<-EOT
            url: $webhook-url
            headers:
            - name: Content-Type
              value: application/json
          EOT
        }
        subscriptions = [
          {
            recipients = ["slack_webhook"]
            triggers = [
              "on-sync-failed",
              "on-health-degraded",
              "on-sync-succeeded",
            ]
          },
        ]
        templates = {
          "template.team9-sync-failed" = <<-EOT
            webhook:
              slack_webhook:
                method: POST
                body: |
                  {
                    "attachments": [{
                      "color": "danger",
                      "title": "[배포 실패] Argo CD - {{.app.metadata.name}}",
                      "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}?operation=true",
                      "fields": [
                        {"title": "서비스", "value": "Argo CD", "short": true},
                        {"title": "심각도", "value": "critical", "short": true},
                        {"title": "환경", "value": "${var.environment}", "short": true},
                        {"title": "대상", "value": "{{.app.metadata.name}}", "short": true},
                        {"title": "상태", "value": "sync failed", "short": true},
                        {"title": "요약", "value": "Git 변경사항을 클러스터에 동기화하지 못했습니다.", "short": false}
                      ]
                    }]
                  }
          EOT
          "template.team9-health-degraded" = <<-EOT
            webhook:
              slack_webhook:
                method: POST
                body: |
                  {
                    "attachments": [{
                      "color": "warning",
                      "title": "[상태 비정상] Argo CD - {{.app.metadata.name}}",
                      "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
                      "fields": [
                        {"title": "서비스", "value": "Argo CD", "short": true},
                        {"title": "심각도", "value": "warning", "short": true},
                        {"title": "환경", "value": "${var.environment}", "short": true},
                        {"title": "대상", "value": "{{.app.metadata.name}}", "short": true},
                        {"title": "상태", "value": "health degraded", "short": true},
                        {"title": "요약", "value": "배포된 애플리케이션의 Health 상태가 Degraded입니다.", "short": false}
                      ]
                    }]
                  }
          EOT
          "template.team9-sync-succeeded" = <<-EOT
            webhook:
              slack_webhook:
                method: POST
                body: |
                  {
                    "attachments": [{
                      "color": "#2f80ed",
                      "title": "[배포 성공] Argo CD - {{.app.metadata.name}}",
                      "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
                      "fields": [
                        {"title": "서비스", "value": "Argo CD", "short": true},
                        {"title": "심각도", "value": "info", "short": true},
                        {"title": "환경", "value": "${var.environment}", "short": true},
                        {"title": "대상", "value": "{{.app.metadata.name}}", "short": true},
                        {"title": "상태", "value": "sync succeeded", "short": true},
                        {"title": "요약", "value": "Git 변경사항이 클러스터에 정상 반영되었습니다.", "short": false}
                      ]
                    }]
                  }
          EOT
        }
        triggers = {
          "trigger.on-sync-failed" = <<-EOT
            - description: Application sync failed.
              oncePer: app.status.operationState.syncResult.revision
              send:
              - team9-sync-failed
              when: app.status.operationState.phase in ['Error', 'Failed']
          EOT
          "trigger.on-health-degraded" = <<-EOT
            - description: Application health degraded.
              oncePer: app.status.health.status
              send:
              - team9-health-degraded
              when: app.status.health.status == 'Degraded'
          EOT
          "trigger.on-sync-succeeded" = <<-EOT
            - description: Application sync succeeded.
              oncePer: app.status.sync.revision
              send:
              - team9-sync-succeeded
              when: app.status.operationState.phase in ['Succeeded']
          EOT
        }
      }
    })
  ]
}
