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
  - `environments/<env>/backend.hcl`
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
terraform init -backend-config=../../environments/dev/backend.hcl
terraform apply -var-file=../../environments/dev/global.tfvars
```

## 설계 원칙

- 각 layer는 별도 state 사용
- 상위 layer는 하위 layer output만 참조
- EKS cluster와 add-on 분리
- 데이터 계층과 플랫폼 계층 분리
- ECR 저장소는 Terraform에서 생성하고, Jenkins/워크로드에서 이를 사용한다
