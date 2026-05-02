# 08-cicd

CI/CD 계층을 관리한다.

- Jenkins on EKS
- ephemeral build agent
- ECR repository bootstrap
- JCasC / Job DSL seed jobs
- GitHub repository webhooks for Jenkins push triggers

## Managed Components

- Jenkins controller and Kubernetes agents
- Jenkins admin, Git, and Slack credentials through External Secrets
- Kaniko service account and ECR push IAM permissions
- ECR repositories and lifecycle policies
- Frontend and backend pipeline jobs generated from Job DSL
- GitHub `push` webhooks pointing at `https://jenkins.team9.cloud.skala-ai.com/github-webhook/`

## GitHub Token

The GitHub provider reads `GITHUB_TOKEN` from the environment. The token must be
able to read and manage repository webhooks for `team-jdd-uta`.

```bash
export GITHUB_TOKEN="$(gh auth token)"
terraform plan -var-file=../../environments/dev/global.tfvars
terraform apply -var-file=../../environments/dev/global.tfvars
```

## Pipeline Repositories

`frontend_pipeline_repo_url` and `backend_pipeline_repositories[*].repo_url`
are the source of truth for both:

- Jenkins pipeline jobs
- GitHub repository webhooks

When adding a new backend service, add it to `backend_pipeline_repositories`.
The next apply will create the Jenkins seed job and the matching GitHub webhook.
