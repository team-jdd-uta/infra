# team9-mini Infra

이 저장소는 `team9-mini` 프로젝트의 AWS 인프라를 Terraform으로 관리하기 위한 코드베이스다.

현재 구조는 `layer` 단위로 분리되어 있고, `dev` 환경은 실제 적용과 기본 동작 확인까지 끝난 상태다.

## 포함 범위

- Frontend
  - S3
  - CloudFront
  - Route 53
  - ACM
- Platform
  - VPC
  - NAT Gateway
  - VPC Endpoint
  - KMS
  - EKS
  - EKS Managed Add-on
- EKS Add-ons
  - Metrics Server
  - KEDA
  - External Secrets Operator
  - cert-manager
  - AWS Load Balancer Controller
  - ExternalDNS
  - Argo CD
- Data
  - RDS MariaDB x3
  - MSK Kafka
  - ElastiCache Redis Pub/Sub
  - DocumentDB
  - Secrets Manager
- Observability
  - kube-prometheus-stack
  - Loki
  - SNS Topic
  - Slack 알림 연동
- CI/CD
  - Jenkins on EKS
  - ECR 기반 이미지 저장소
  - RTMP 전용 `team9-rtmp` 이미지 저장소
  - Jenkins seed job
  - GitHub repository webhook
- Auth
  - Cognito User Pool/App Client
  - login-service Cognito IRSA role

## 디렉터리 구조

```text
infra/
  README.md
  .gitignore
  terraform/
    README.md
    environments/
    layers/
    modules/
```

세부 Terraform 구조는 [terraform/README.md](./terraform/README.md)에 정리되어 있다.
환경별 보안/운영 전환 기준은 [terraform/README.md](./terraform/README.md)의 "환경별 안전성 기준"을 먼저 확인한다.

## Layer 순서

생성 순서:

1. `01-bootstrap`
2. `02-foundation`
3. `03-edge`
4. `04-platform-eks`
5. `05-platform-addons`
6. `06-data`
7. `07-observability`
8. `08-cicd`
9. `09-auth`

삭제는 반드시 역순으로 진행한다.

1. `09-auth`
2. `08-cicd`
3. `07-observability`
4. `06-data`
5. `05-platform-addons`
6. `04-platform-eks`
7. `03-edge`
8. `02-foundation`
9. `01-bootstrap`

## 현재 dev 기준 주요 자원

- Terraform backend
  - S3 bucket: `team9-mini-dev-terraform-state`
  - DynamoDB lock table: `team9-mini-dev-terraform-lock`
- EKS
  - Cluster: `team9-mini-dev-eks`
  - Node group: `team9-mini-dev-general`
  - Node group: `team9-mini-dev-build`
- Frontend
  - S3 bucket: `team9-mini-dev-frontend`
- Data
  - RDS: `team9-mini-dev-db-01`
  - RDS: `team9-mini-dev-db-02`
  - RDS: `team9-mini-dev-db-03`
  - MSK: `team9-mini-dev-msk`
  - Redis Pub/Sub: `team9-mini-dev-redis-pubsub`
  - DocumentDB: `team9-mini-dev-documentdb`
- CI/CD
  - Jenkins: `https://jenkins.team9.cloud.skala-ai.com`
  - ECR: `team9-user-service`, `team9-login-service`, `team9-room-service`, `team9-chat-service`,
    `team9-socket-io-gateway`, `team9-redis-stream-mongo-consumer`, `team9-rtmp`, `team9-ui-vue`
  - GitHub webhook URL: `https://jenkins.team9.cloud.skala-ai.com/github-webhook/`
- Auth
  - Cognito User Pool/App Client
  - login-service service account용 Cognito IRSA role

## 실행 전 준비

필수:

- AWS CLI 인증
- Terraform 설치
- kubectl 설치
- Helm 설치
- GitHub CLI `gh` 설치
- GitHub webhook을 적용할 때 사용할 `GITHUB_TOKEN`

환경 파일:

- 예시 파일을 복사해서 실제 파일을 만든다.
- 실제 파일은 Git에 올리지 않는다.

예시:

```bash
cp terraform/environments/dev/global.tfvars.example terraform/environments/dev/global.tfvars
cp terraform/environments/dev/backend.hcl.example terraform/environments/dev/backend.hcl
```

## 생성 방법

### 1. Bootstrap

`01-bootstrap`은 local state로 실행한다.

```bash
cd terraform/layers/01-bootstrap
terraform init -backend=false
terraform plan -var-file=../../environments/dev/global.tfvars
terraform apply -var-file=../../environments/dev/global.tfvars
```

### 2. 나머지 Layer

`02` 이후는 S3 backend + DynamoDB lock을 사용한다.

```bash
cd terraform/layers/02-foundation
terraform init -backend-config=../../environments/dev/backend.hcl
terraform plan -var-file=../../environments/dev/global.tfvars
terraform apply -var-file=../../environments/dev/global.tfvars
```

`03` 이후도 같은 방식으로 layer 디렉터리만 바꿔서 적용한다.

레이어별 backend key를 분리해서 쓰고 싶다면 `backend-02-foundation.hcl` 같은 파일을 환경별로 따로 만들어 사용하면 된다.

`08-cicd`는 GitHub repository webhook도 관리하므로 GitHub token이 필요하다.

```bash
export GITHUB_TOKEN="$(gh auth token)"

cd terraform/layers/08-cicd
terraform init -backend-config=../../environments/dev/backend.hcl
terraform plan -var-file=../../environments/dev/global.tfvars
terraform apply -var-file=../../environments/dev/global.tfvars
```

## 삭제 방법

삭제는 역순으로 진행한다.

예시:

```bash
cd terraform/layers/08-cicd
terraform init -backend-config=../../environments/dev/backend.hcl
terraform destroy -var-file=../../environments/dev/global.tfvars
```

실제 삭제 시에는 위의 삭제 순서에 맞춰 `09-auth`부터 시작하고, 그 다음 `08-cicd`,
`07-observability`, `06-data` 순서로 내려간다.

주의:

- `01-bootstrap`은 마지막에 삭제한다.
- `CloudFront`, `RDS`, `DocumentDB`, `MSK`는 삭제 시간이 오래 걸릴 수 있다.
- 실제 운영 환경에서는 destroy 전에 백업 여부를 먼저 확인해야 한다.

## Git에 올리지 않는 항목

다음은 `.gitignore`로 제외한다.

- `.terraform/`
- `terraform.tfstate*`
- `*.tfplan`
- 실제 `backend*.hcl`
- 실제 `global.tfvars`
- 로컬 Terraform CLI 설정 파일

즉 저장소에는 코드와 예시 설정만 올라가고, 실제 환경값과 state는 올라가지 않는다.

## 운영 메모

- `05-platform-addons`는 External Secrets Operator, AWS Load Balancer Controller,
  ExternalDNS, Argo CD, Stakater Reloader를 관리한다.
- `06-data`는 RDS/MSK/DocumentDB/Redis PubSub과 서비스용 Secrets Manager 값을 관리한다.
- `08-cicd`는 Jenkins job과 ECR뿐 아니라 GitHub repository webhook도 관리한다.
  기존 수동 webhook은 Terraform state로 import되어 있으며, 신규 서비스는
  `backend_pipeline_repositories`에 추가하면 Jenkins seed job과 GitHub webhook이 함께 관리된다.
- Slack 알림은 Secrets Manager의 Slack webhook 값을 ExternalSecret으로 가져와
  Jenkins, Argo CD, Alertmanager/Grafana 쪽에서 사용한다.
- GitOps 애플리케이션 정의와 서비스별 이미지 태그는 `gitops` 저장소가 담당한다.
