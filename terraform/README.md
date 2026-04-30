# Terraform Layout

이 디렉터리는 `team9-mini` AWS 인프라를 layer 기반으로 관리하는 Terraform 코드다.

## 구조

```text
terraform/
  README.md
  environments/
    dev/
      backend.hcl.example
      global.tfvars.example
    stage/
      backend.hcl.example
      global.tfvars.example
    prod/
      backend.hcl.example
      global.tfvars.example
  layers/
    01-bootstrap/
    02-foundation/
    03-edge/
    04-platform-eks/
    05-platform-addons/
    06-data/
    07-observability/
    08-cicd/
  modules/
    bootstrap-backend/
    foundation/
    edge/
    platform-eks/
    platform-addons/
    data/
    observability/
    cicd/
```

## Layer 역할

1. `01-bootstrap`
   - Terraform backend용 S3, DynamoDB
2. `02-foundation`
   - VPC, subnet, NAT, route, KMS, VPC endpoint
3. `03-edge`
   - ACM, Route 53, S3 frontend, CloudFront
4. `04-platform-eks`
   - EKS, node group, OIDC, managed add-on
5. `05-platform-addons`
   - cert-manager, ESO, ALB controller, ExternalDNS, Argo CD, metrics-server
6. `06-data`
   - RDS, MSK, DocumentDB, Secrets Manager
7. `07-observability`
   - Prometheus, Grafana, Loki, SNS
8. `08-cicd`
   - Jenkins on EKS

## Backend 원칙

- `01-bootstrap`만 local state
- `02` 이후는 S3 backend + DynamoDB lock
- layer마다 state key를 분리

## 예시 파일

- 실제 실행 파일:
  - `environments/<env>/global.tfvars`
  - `environments/<env>/backend-<layer>.hcl`
- 저장소에 포함되는 예시 파일:
  - `environments/<env>/global.tfvars.example`
  - `environments/<env>/backend.hcl.example`

## 기본 실행 예시

```bash
cd terraform/layers/01-bootstrap
terraform init -backend=false
terraform apply -var-file=../../environments/dev/global.tfvars
```

```bash
cd terraform/layers/02-foundation
terraform init -backend-config=../../environments/dev/backend-02-foundation.hcl
terraform apply -var-file=../../environments/dev/global.tfvars
```

## 설계 원칙

- 각 layer는 별도 state 사용
- 상위 layer는 하위 layer output만 참조
- EKS cluster와 add-on 분리
- 데이터 계층과 플랫폼 계층 분리
- ECR 저장소는 Terraform에서 생성하고, Jenkins/워크로드에서 이를 사용한다

## 실제값 체크리스트

아래 값들은 현재 example 값으로만 들어 있다. 실제 적용 전 반드시 환경값으로 교체해야 한다.

### `06-data`

- `environments/<env>/global.tfvars`
  - `msk_broker_instance_type`
  - `msk_kafka_version`
  - `msk_number_of_broker_nodes`
- 확인 항목
  - 브로커 노드 수가 subnet/AZ 설계와 맞는지
  - Kafka client 인증 방식을 IAM으로 유지할지
  - 토픽 생성 정책을 애플리케이션/운영 도구 중 어디서 관리할지

### `08-cicd`

- `environments/<env>/global.tfvars`
  - `ecr_frontend_repository_name`
  - `ecr_backend_repository_names`
  - `jenkins_git_credentials_id`
  - `jenkins_admin_secret_name`
  - `jenkins_admin_k8s_secret_name`
  - `jenkins_git_credentials_secret_name`
  - `jenkins_git_k8s_secret_name`
  - `external_secrets_cluster_secret_store_name`
  - `frontend_pipeline_job_name`
  - `frontend_pipeline_repo_url`
  - `frontend_pipeline_repo_branch`
  - `frontend_pipeline_jenkinsfile_path`
  - `backend_pipeline_repositories[*].job_name`
  - `backend_pipeline_repositories[*].repo_url`
  - `backend_pipeline_repositories[*].branch`
  - `backend_pipeline_repositories[*].jenkinsfile_path`

## Secrets Manager로 넘길 값

현재 예시에서는 Jenkins 관련 민감값이 `global.tfvars.example`에 평문으로 보이도록 남겨져 있다. 실제 운영에서는 아래 값을 Secrets Manager로 옮기는 편이 맞다.

### 권장 비밀 목록

- `team9-mini/<env>/jenkins/admin`
  - `username`
  - `password`
- `team9-mini/<env>/jenkins/git-credentials`
  - `username`
  - `token`

필요하면 아래도 분리할 수 있다.

- `team9-mini/<env>/argocd/repositories/backend`
  - `url`
  - `username`
  - `token`
- `team9-mini/<env>/argocd/repositories/frontend`
  - `url`
  - `username`
  - `token`
- `team9-mini/<env>/argocd/repositories/gitops`
  - `url`
  - `username`
  - `token`

## 적용 방법

권장 적용 순서는 아래와 같다.

1. `global.tfvars.example`를 복사해 실제 `global.tfvars`를 만든다.
2. 비민감 값만 `global.tfvars`에 남긴다.
3. Jenkins 관리자 계정과 Git token은 Secrets Manager에 먼저 저장한다.
4. `05-platform-addons`에서 ESO IRSA와 `ClusterSecretStore`를 먼저 생성한다.
5. `08-cicd`가 Jenkins namespace의 `ExternalSecret`과 Helm/JCasC를 통해 Secrets Manager 값을 읽도록 적용한다.

현재 저장소 기준에서 남은 연결 작업은 다음이다.

### 1. Secrets Manager에 실제 비밀 생성

예시:

```bash
aws secretsmanager create-secret \
  --name team9-mini/dev/jenkins/admin \
  --secret-string '{"username":"admin","password":"REPLACE_ME"}'
```

```bash
aws secretsmanager create-secret \
  --name team9-mini/dev/jenkins/git-credentials \
  --secret-string '{"username":"REPLACE_ME","token":"REPLACE_ME"}'
```

### 2. `05-platform-addons` 적용

이 layer는 아래 항목을 만든다.

- `external-dns`용 IRSA role
- `external-secrets`용 IRSA role
- `ClusterSecretStore/aws-secretsmanager`

출력값은 다음처럼 확인할 수 있다.

```bash
terraform -chdir=layers/05-platform-addons output external_dns_role_arn
terraform -chdir=layers/05-platform-addons output external_secrets_role_arn
terraform -chdir=layers/05-platform-addons output cluster_secret_store_name
```

### 3. `08-cicd` 적용

이 layer는 아래 흐름으로 Jenkins 비밀을 연결한다.

- Secrets Manager secret name을 `global.tfvars`로 전달
- Jenkins namespace에 `ExternalSecret` 2개 생성
- Jenkins Helm chart는 `controller.admin.existingSecret`으로 관리자 계정을 읽음
- Jenkins JCasC는 mounted secret key를 통해 Git credential을 읽음

즉 현재 상태는 "Secret Manager -> ExternalSecret -> Jenkins Secret -> JCasC 참조" 흐름까지 저장소에 반영된 상태"다.
