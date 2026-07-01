# Core Infra Terraform 모듈화 기회 분석

## 상태
* 2026-06-30 Draft

## 1. 목적 및 범위

### 분석 목적
한진그룹 통합 랜딩존의 Core Infra 14개 계정에 대해 Terraform 모듈화가 의미 있는 대상을 식별하고, 모듈화 우선순위를 제시한다.

### 분석 대상
**기존 계정 (9개)**
1. Management Account (hgaws)
2. Core Network
3. Perimeter
4. Github Management
5. Identity Center Management
6. AFT Management
7. OU Management
8. Audit
9. Log Archive

**계획 계정 (5개)**
10. Security Tooling
11. Break Glass
12. Backup
13. Observability
14. CICD

### 관련 문서
- [ADR-002: IaC 모듈화 전략](../../40_Project_Deliverables/Architecture_Decision_Records/ADR-002_IaC_모듈화_전략.md)
- [ADR-016: Core Infra pipeline 설계](../../40_Project_Deliverables/Architecture_Decision_Records/ADR-016_Core_Infra_pipeline_설계.md)
- [ADR-020: 계정 벤딩 권한부여 설계](../../40_Project_Deliverables/Architecture_Decision_Records/ADR-020_계정_벤딩_권한부여_설계.md)
- [OU 계정 구조](../../40_Project_Deliverables/10_Architecture_Design/OU_계정_구조.md)

---

## 2. 파이프라인 실행 체계 요약

### AFT Pipeline vs GitHub Actions Pipeline

| 항목 | AFT Pipeline | GitHub Actions Pipeline |
|------|-------------|------------------------|
| **실행 주체** | AFT Management 계정 | 각 위임 계정 |
| **트리거** | Account Request DynamoDB 변경 | PR 생성/머지 |
| **배포 대상** | 계정 생성 시점 baseline 리소스 | 계정 생성 이후 운영 인프라 |
| **State 위치** | AFT 관리 S3 (계정별 분리) | 각 계정 독립 S3 |
| **인증 방식** | AFT 내부 역할 체인 | OIDC → Broker Role → Execution Role |
| **사용 Repository** | aws-aft-* 4개 repo | infrastructure-*, management-*, root-* repo |

### 인증 경로

#### AFT Pipeline
```
AFT CodePipeline (AFT Management)
  ↓
Target Account
  ↓
Customization 실행 (Terraform/Shell)
```

#### GitHub Actions Pipeline
```
GitHub Actions Workflow
  ↓
OIDC Provider (GitHub Management 계정)
  ↓
Broker Role (Plan/Apply per account)
  ↓
Execution Role (Target Account)
  ↓
Terraform 실행
```

---

## 3. 계정별 상세 분석

### 3.1 Management Account (hgaws)

#### 역할 정의
- Control Tower 기능 위임 설정 (Trusted Access + Delegated Administrator)
- Organizations 거버넌스 정책 관리 (SCP, Tag Policy, Backup Policy 등)
- Cross-Account 접근 역할 제공 (OU Management, GitHub Management 등에게)
- 통합 결제 계정

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| MGT-01 | State Backend 구성 | S3, KMS | GitHub Actions | Management | root-hgaws/state-backend | 구현됨 | Tier 3 |
| MGT-02 | Organizations 생성 | aws_organizations_organization | GitHub Actions | Management | aws-ct-management/management-bootstrap | 구현됨 | Tier 3 |
| MGT-03 | 최상위 OU 생성 | aws_organizations_organizational_unit | GitHub Actions | Management | aws-ct-management/organizations | 구현됨 | Tier 3 |
| MGT-04 | Audit/Log Archive 계정 생성 | aws_organizations_account | GitHub Actions | Management | aws-ct-management/pre-lz-accounts | 구현됨 | Tier 3 |
| MGT-05 | Control Tower KMS Key 생성 | aws_kms_key | GitHub Actions | Management | aws-ct-management/control-tower-kms | 구현됨 | Tier 3 |
| MGT-06 | Control Tower Landing Zone 배포 | aws_controltower_landing_zone | GitHub Actions | Management | aws-ct-management/control-tower | 구현됨 | Tier 3 |
| MGT-07 | Delegated Administrator 등록 | aws_organizations_delegated_administrator | GitHub Actions | Management | root-hgaws/delegated-administrator | 구현됨 | Tier 3 |
| MGT-08 | OU Management 접근 역할 제공 | aws_iam_role | GitHub Actions | Management | root-hgaws/assumed-roles | 구현됨 | Tier 3 |
| MGT-09 | GitHub Management 접근 역할 제공 | aws_iam_role | GitHub Actions | Management | root-hgaws/assumed-roles | 구현됨 | Tier 3 |
| MGT-10 | SCP 정책 생성 및 부착 | aws_organizations_policy | GitHub Actions | Management | - | 예상 | Tier 3 |
| MGT-11 | Tag Policy 생성 및 부착 | aws_organizations_policy | GitHub Actions | Management | - | 예상 | Tier 3 |
| MGT-12 | Backup Policy 생성 | aws_organizations_policy | GitHub Actions | Management | - | 예상 | Tier 3 |
| MGT-13 | Trusted Access 활성화 | aws_organizations_organization | GitHub Actions | Management | - | 예상 | Tier 3 |

---

### 3.2 Core Network

#### 역할 정의
- 전사 공유 네트워크 인프라 소유 (TGW, IPAM, Inspection VPC)
- Shared Endpoints (Interface/Gateway Endpoints) 관리
- DNS Hub (Route 53 Resolver Rule, Private Hosted Zone)
- Hybrid Connectivity (Direct Connect, VPN) 관리
- RAM Share를 통한 네트워크 리소스 공유

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| CN-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | aws-aft-account-customizations/infra-core-network | 구현됨 | **Tier 1** |
| CN-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | aws-aft-account-customizations/infra-core-network | 구현됨 | **Tier 1** |
| CN-03 | IPAM 계층 구성 | aws_vpc_ipam, aws_vpc_ipam_pool | GitHub Actions | Core Network | infrastructure-corenetwork/core-network-ipam | 구현됨 | Tier 3 |
| CN-04 | Core Platform VPC 생성 | aws_vpc, aws_subnet | GitHub Actions | Core Network | infrastructure-corenetwork/core-platform-vpc-foundation | 구현됨 | Tier 2 |
| CN-05 | Transit Gateway 생성 | aws_ec2_transit_gateway | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-06 | TGW Route Table 구성 | aws_ec2_transit_gateway_route_table | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-07 | TGW Attachment 관리 | aws_ec2_transit_gateway_vpc_attachment | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-08 | RAM Share 생성 (TGW) | aws_ram_resource_share | GitHub Actions | Core Network | - | 예상 | **Tier 2** |
| CN-09 | Inspection VPC 생성 | aws_vpc | GitHub Actions | Core Network | - | 예상 | Tier 2 |
| CN-10 | Network Firewall 배포 | aws_networkfirewall_firewall | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-11 | Route 53 Resolver Rule 생성 | aws_route53_resolver_rule | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-12 | Resolver Rule RAM Share | aws_ram_resource_share | GitHub Actions | Core Network | - | 예상 | **Tier 2** |
| CN-13 | Private Hosted Zone 관리 | aws_route53_zone | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-14 | VPC Endpoints (Shared) | aws_vpc_endpoint | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-15 | Direct Connect Gateway | aws_dx_gateway | GitHub Actions | Core Network | - | 예상 | Tier 3 |
| CN-16 | VPN Connection | aws_vpn_connection | GitHub Actions | Core Network | - | 예상 | Tier 3 |

---

### 3.3 Perimeter

#### 역할 정의
- Ingress/Egress 경계 계정
- AWS Network Firewall 관리
- WAF (Web Application Firewall) 중앙 관리
- NLB (경계 로드밸런서)
- 외부 트래픽 진입/출구 통제

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| PM-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | aws-aft-account-customizations/infra-perimeter | 구현됨 | **Tier 1** |
| PM-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | aws-aft-account-customizations/infra-perimeter | 구현됨 | **Tier 1** |
| PM-03 | Ingress VPC 생성 | aws_vpc, aws_subnet | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 2 |
| PM-04 | Egress VPC 생성 | aws_vpc, aws_subnet | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 2 |
| PM-05 | Network Firewall 배포 (경계) | aws_networkfirewall_firewall | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-06 | Firewall Policy 관리 | aws_networkfirewall_firewall_policy | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-07 | WAFv2 WebACL 생성 | aws_wafv2_web_acl | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-08 | NLB (Ingress) | aws_lb | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-09 | ALB (Egress Proxy) | aws_lb | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-10 | TGW Attachment (Ingress/Egress) | aws_ec2_transit_gateway_vpc_attachment | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |
| PM-11 | Route Table 구성 (경계 라우팅) | aws_route_table | GitHub Actions | Perimeter | infrastructure-perimeter | 예상 | Tier 3 |

---

### 3.4 Github Management

#### 역할 정의
- GitHub OIDC IdP 소유
- 각 계정별 Broker Role 관리 (Plan/Apply)
- Self-hosted GitHub Actions Runner 인프라 운영
- Terraform 실행을 위한 중앙 인증 허브

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| GH-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | **Tier 1** |
| GH-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | **Tier 1** |
| GH-03 | GitHub OIDC IdP 생성 | aws_iam_openid_connect_provider | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-04 | Broker Role 생성 (각 계정별) | aws_iam_role (for_each) | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | **Tier 2** |
| GH-05 | Runner VPC 생성 | aws_vpc, aws_subnet | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 2 |
| GH-06 | Runner ASG 구성 | aws_launch_template, aws_autoscaling_group | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-07 | Webhook Lambda 배포 | aws_lambda_function, API Gateway | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-08 | Runner State DynamoDB | aws_dynamodb_table | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-09 | EC2 Image Builder (Runner AMI) | aws_imagebuilder_* | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-10 | CloudWatch Logs 구성 | aws_cloudwatch_log_group | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |
| GH-11 | GitHub App 자격증명 관리 | aws_ssm_parameter | AFT | AFT Management | aws-aft-account-customizations/infra-github-management | 구현됨 | Tier 3 |

---

### 3.5 Identity Center Management

#### 역할 정의
- IAM Identity Center 위임 관리자
- Permission Set 생성/관리
- Account Assignment (사용자/그룹 → 계정 접근 권한)
- SSO 접근 로그 및 감사

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| IC-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | aws-aft-account-customizations/infra-identity-center-management | 구현됨 | **Tier 1** |
| IC-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | aws-aft-account-customizations/infra-identity-center-management | 구현됨 | **Tier 1** |
| IC-03 | Permission Set 생성 | aws_ssoadmin_permission_set | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-04 | Permission Set Inline Policy | aws_ssoadmin_permission_set_inline_policy | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-05 | Managed Policy 부착 | aws_ssoadmin_managed_policy_attachment | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-06 | Account Assignment | aws_ssoadmin_account_assignment | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-07 | Identity Store 그룹 관리 | aws_identitystore_group | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-08 | Identity Store 사용자 관리 | aws_identitystore_user | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |
| IC-09 | Group Membership 관리 | aws_identitystore_group_membership | GitHub Actions | Identity Center Management | infrastructure-identitycenter | 예상 | Tier 3 |

---

### 3.6 AFT Management

#### 역할 정의
- Account Factory for Terraform 엔진 운영
- 신규 계정 vending
- AFT Customization 실행 (global, account-specific)
- AFT 파이프라인 (CodePipeline, Step Functions, Lambda)

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| AFT-01 | AFT Management 계정 생성 | aws_servicecatalog_provisioned_product | GitHub Actions | Management | aws-aft-management/aft-management-account | 구현됨 | Tier 3 |
| AFT-02 | AFT 모듈 배포 | module (upstream) | GitHub Actions | AFT Management | aws-aft-management | 구현됨 | Tier 3 |
| AFT-03 | Account Request 정의 | aws_dynamodb_table_item | AFT | AFT Management | aws-aft-account-request | 구현됨 | Tier 3 |
| AFT-04 | Global Customization 관리 | Shell Script | AFT | AFT Management | aws-aft-global-customizations | 구현됨 | Tier 3 |
| AFT-05 | Account Customization 관리 | Terraform | AFT | AFT Management | aws-aft-account-customizations | 구현됨 | Tier 3 |
| AFT-06 | Provisioning Customization | Step Functions | AFT | AFT Management | aws-aft-account-provisioning-customizations | 구현됨 | Tier 3 |
| AFT-07 | Default VPC 삭제 자동화 | Shell Script | AFT | AFT Management | aws-aft-global-customizations | 구현됨 | Tier 3 |

---

### 3.7 OU Management

#### 역할 정의
- OU 구조 관리 (1~3 depth, YAML 기반)
- Control Tower Baseline 등록/업데이트 자동화
- Organizations API 호출 (Management Account 역할 assume)

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| OU-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | aws-aft-account-customizations/management-ou-management | 구현됨 | **Tier 1** |
| OU-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | aws-aft-account-customizations/management-ou-management | 구현됨 | **Tier 1** |
| OU-03 | 2-depth OU 생성 (YAML 기반) | aws_organizations_organizational_unit | GitHub Actions | OU Management (→ Management) | management-ou | 구현됨 | Tier 3 |
| OU-04 | 3-depth OU 생성 (YAML 기반) | aws_organizations_organizational_unit | GitHub Actions | OU Management (→ Management) | management-ou | 구현됨 | Tier 3 |
| OU-05 | Control Tower Baseline 등록 (2-depth) | aws_controltower_baseline | GitHub Actions | OU Management (→ Management) | management-ou | 구현됨 | Tier 3 |
| OU-06 | Control Tower Baseline 등록 (3-depth) | aws_controltower_baseline | GitHub Actions | OU Management (→ Management) | management-ou | 구현됨 | Tier 3 |
| OU-07 | OU Discovery Lambda | aws_lambda_function | GitHub Actions | Management | root-hgaws/step-functions | 구현됨 | Tier 3 |
| OU-08 | Baseline 등록 자동화 Step Functions | aws_sfn_state_machine | GitHub Actions | Management | root-hgaws/step-functions | 구현됨 | Tier 3 |

---

### 3.8 Audit

#### 역할 정의
- Control Tower 보안 감사 계정
- Trusted Advisor 위임 대상
- 조직 전체 감사 로그 집계
- 컴플라이언스 리포트 생성

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| AUD-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 예상 | **Tier 1** |
| AUD-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 예상 | **Tier 1** |
| AUD-03 | Trusted Advisor 위임 수신 | - | Manual/API | Management | - | 예상 | Tier 3 |
| AUD-04 | Config Aggregator 설정 | aws_config_configuration_aggregator | GitHub Actions | Audit | - | 예상 | Tier 3 |
| AUD-05 | 감사 로그 분석 Lambda | aws_lambda_function | GitHub Actions | Audit | - | 예상 | Tier 3 |
| AUD-06 | 컴플라이언스 리포트 생성 | EventBridge + Lambda | GitHub Actions | Audit | - | 예상 | Tier 3 |
| AUD-07 | SNS Topic (감사 알림) | aws_sns_topic | GitHub Actions | Audit | - | 예상 | Tier 3 |

---

### 3.9 Log Archive

#### 역할 정의
- 전사 중앙 로그 저장소
- CloudTrail, Config, VPC Flow Logs 장기 보관
- S3 Lifecycle 기반 로그 아카이빙
- Security Hub, GuardDuty 로그 수집

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| LOG-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 예상 | **Tier 1** |
| LOG-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 예상 | **Tier 1** |
| LOG-03 | 중앙 로그 S3 Bucket | aws_s3_bucket | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-04 | S3 Lifecycle Policy | aws_s3_bucket_lifecycle_configuration | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-05 | CloudTrail Organization Trail 수신 | aws_s3_bucket_policy | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-06 | VPC Flow Logs 집계 | aws_s3_bucket_policy | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-07 | Config 로그 수신 | aws_s3_bucket_policy | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-08 | GuardDuty Findings 저장 | aws_s3_bucket_policy | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-09 | Security Hub Findings 저장 | aws_s3_bucket_policy | GitHub Actions | Log Archive | - | 예상 | Tier 3 |
| LOG-10 | Glacier 아카이빙 설정 | S3 Lifecycle | GitHub Actions | Log Archive | - | 예상 | Tier 3 |

---

### 3.10 Security Tooling (계획)

#### 역할 정의
- Security Hub 위임 관리자
- GuardDuty 위임 관리자
- Macie, Config, Inspector, Detective 위임 관리자
- 전사 보안 서비스 중앙 집계 및 정책 배포
- 보안 이벤트 자동화 대응

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| SEC-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 계획 | **Tier 1** |
| SEC-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 계획 | **Tier 1** |
| SEC-03 | Security Hub 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-04 | Security Hub 조직 전체 활성화 | aws_securityhub_organization_configuration | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |
| SEC-05 | Security Standards 활성화 | aws_securityhub_standards_subscription | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |
| SEC-06 | GuardDuty 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-07 | GuardDuty Detector 조직 배포 | aws_guardduty_organization_configuration | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |
| SEC-08 | Macie 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-09 | Macie 조직 전체 활성화 | aws_macie2_organization_admin_account | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |
| SEC-10 | Config 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-11 | Inspector 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-12 | Detective 위임 수신 | - | Manual | Management | - | 계획 | Tier 3 |
| SEC-13 | 보안 이벤트 자동화 (EventBridge) | aws_cloudwatch_event_rule | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |
| SEC-14 | 보안 대응 Lambda | aws_lambda_function | GitHub Actions | Security Tooling | - | 계획 | Tier 3 |

---

### 3.11 Break Glass (계획)

#### 역할 정의
- 긴급 접근 전용 독립 계정
- SSO/IAM 장애 시 비상 복구 경로
- 최소 권한, 강력한 MFA
- 모든 접근 전체 감사 로깅

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| BG-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 계획 | **Tier 1** |
| BG-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 계획 | **Tier 1** |
| BG-03 | 긴급 접근 IAM User 생성 | aws_iam_user | GitHub Actions | Break Glass | - | 계획 | Tier 3 |
| BG-04 | MFA 강제 정책 | aws_iam_user_policy | GitHub Actions | Break Glass | - | 계획 | Tier 3 |
| BG-05 | 최소 권한 정책 부착 | aws_iam_user_policy_attachment | GitHub Actions | Break Glass | - | 계획 | Tier 3 |
| BG-06 | 접근 로그 CloudTrail | aws_cloudtrail | GitHub Actions | Break Glass | - | 계획 | Tier 3 |
| BG-07 | 로그인 알림 (SNS) | aws_sns_topic, EventBridge | GitHub Actions | Break Glass | - | 계획 | Tier 3 |
| BG-08 | 접근 시도 모니터링 CloudWatch Alarm | aws_cloudwatch_metric_alarm | GitHub Actions | Break Glass | - | 계획 | Tier 3 |

---

### 3.12 Backup (계획)

#### 역할 정의
- AWS Backup 중앙 관리
- 전사 백업 정책 정의 및 강제
- 크로스 계정 백업 vault 소유
- 백업 컴플라이언스 리포트

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| BAK-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 계획 | **Tier 1** |
| BAK-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 계획 | **Tier 1** |
| BAK-03 | 중앙 Backup Vault 생성 | aws_backup_vault | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-04 | Backup Vault Lock 정책 | aws_backup_vault_lock_configuration | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-05 | Backup Plan 정의 | aws_backup_plan | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-06 | Backup Selection (리소스 태그 기반) | aws_backup_selection | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-07 | 크로스 계정 Backup 역할 | aws_iam_role | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-08 | 백업 컴플라이언스 리포트 | AWS Backup Audit Manager | GitHub Actions | Backup | - | 계획 | Tier 3 |
| BAK-09 | Backup 실패 알림 | EventBridge + SNS | GitHub Actions | Backup | - | 계획 | Tier 3 |

---

### 3.13 Observability (계획)

#### 역할 정의
- CloudWatch 크로스 계정 집계
- 전사 통합 모니터링 대시보드
- 비용 대시보드 (Cost Explorer)
- 운영 메트릭 시각화

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| OBS-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 계획 | **Tier 1** |
| OBS-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 계획 | **Tier 1** |
| OBS-03 | CloudWatch Cross-Account Observability | aws_oam_sink | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-04 | 통합 대시보드 생성 | aws_cloudwatch_dashboard | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-05 | 비용 대시보드 (QuickSight) | aws_quicksight_dashboard | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-06 | Cost Anomaly Detection | aws_ce_anomaly_monitor | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-07 | 비용 알림 (Budget) | aws_budgets_budget | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-08 | 메트릭 수집 Lambda | aws_lambda_function | GitHub Actions | Observability | - | 계획 | Tier 3 |
| OBS-09 | 커스텀 메트릭 게시 | CloudWatch PutMetricData | GitHub Actions | Observability | - | 계획 | Tier 3 |

---

### 3.14 CICD (계획)

#### 역할 정의
- Workload 애플리케이션 배포 파이프라인
- Golden AMI 빌드 (EC2 Image Builder)
- 컨테이너 이미지 레지스트리 (ECR 공유)
- 애플리케이션 artifact 저장소

#### 업무 목록

| Task ID | 작업명 | 리소스 유형 | 실행 방식 | 실행 계정 | Repository/폴더 | 구현 상태 | 모듈화 Tier |
|---------|--------|------------|----------|----------|----------------|----------|------------|
| CI-01 | State Backend 구성 | S3, KMS | AFT | AFT Management | - | 계획 | **Tier 1** |
| CI-02 | Execution Role 생성 | IAM Role, Policy | AFT | AFT Management | - | 계획 | **Tier 1** |
| CI-03 | ECR Repository (공유 이미지) | aws_ecr_repository | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-04 | ECR Repository Policy (RAM Share) | aws_ecr_repository_policy | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-05 | Golden AMI Image Builder Pipeline | aws_imagebuilder_image_pipeline | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-06 | AMI Distribution 설정 | aws_imagebuilder_distribution_configuration | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-07 | CodeArtifact Repository | aws_codeartifact_repository | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-08 | CodePipeline (Workload 배포) | aws_codepipeline | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-09 | CodeBuild Project | aws_codebuild_project | GitHub Actions | CICD | - | 계획 | Tier 3 |
| CI-10 | Artifact S3 Bucket | aws_s3_bucket | GitHub Actions | CICD | - | 계획 | Tier 3 |

---

## 4. 크로스 계정 공통 패턴 식별 및 Tier 분류

### Tier 1: 동일 Boilerplate (90%+ 코드 일치) → 즉시 모듈화 권장

#### 1. State Bootstrap 패턴

**적용 계정:** 9개
- 구현됨: Core Network, Perimeter, Identity Center Management, Github Management, OU Management
- 계획: Audit, Log Archive, Security Tooling, Break Glass, Backup, Observability, CICD

**현재 중복 코드 위치:**
```
aws-aft-account-customizations/infra-core-network/terraform/main.tf (lines 1-95)
aws-aft-account-customizations/infra-perimeter/terraform/main.tf (lines 1-95)
aws-aft-account-customizations/infra-identity-center-management/terraform/main.tf (lines 1-95)
aws-aft-account-customizations/management-ou-management/terraform/main.tf (lines 1-95)
```

**포함 리소스:**
- `aws_kms_key` (state encryption)
- `aws_kms_alias`
- `aws_s3_bucket`
- `aws_s3_bucket_versioning`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_policy`

**중복 코드 예상:** ~100 LOC × 9 = 900 LOC

**모듈 인터페이스 (예상):**
```hcl
module "state_bootstrap" {
  source = "git::https://github.com/org/terraform-modules.git//state-bootstrap?ref=v1.0.0"
  
  account_name                = "core-network"
  github_management_account_id = "391940625848"
  tags                        = local.common_tags
}

# Output
# - state_bucket_name
# - state_kms_key_arn
```

**모듈화 시 이점:**
- 신규 계정 온보딩 시간 80% 단축
- S3/KMS 보안 설정 표준 강제
- 버킷명 네이밍 규칙 자동 적용

---

#### 2. Execution Role Pair 패턴

**적용 계정:** 9개 (State Bootstrap과 동일)

**현재 중복 코드 위치:**
```
aws-aft-account-customizations/infra-core-network/terraform/main.tf (lines 96-180)
aws-aft-account-customizations/infra-perimeter/terraform/main.tf (lines 96-180)
aws-aft-account-customizations/infra-identity-center-management/terraform/main.tf (lines 96-180)
aws-aft-account-customizations/management-ou-management/terraform/main.tf (lines 96-180)
```

**포함 리소스:**
- `aws_iam_role` (plan_execution)
- `aws_iam_role` (apply_execution)
- `aws_iam_role_policy` (plan - state read)
- `aws_iam_role_policy` (apply - state write)
- Trust Policy (GitHub Management broker role 신뢰)

**중복 코드 예상:** ~80 LOC × 9 = 720 LOC

**주의사항:**
- 도메인별 IAM Policy는 모듈에 포함되지 않음
- State 접근 권한만 모듈로 추출, 도메인 권한은 호출자가 별도 부착

**모듈 인터페이스 (예상):**
```hcl
module "execution_roles" {
  source = "git::https://github.com/org/terraform-modules.git//execution-roles?ref=v1.0.0"
  
  account_name          = "core-network"
  state_bucket_arn      = module.state_bootstrap.bucket_arn
  state_kms_key_arn     = module.state_bootstrap.kms_key_arn
  broker_role_plan_arn  = "arn:aws:iam::391940625848:role/..."
  broker_role_apply_arn = "arn:aws:iam::391940625848:role/..."
}

# 호출자가 추가로 domain policy 부착
resource "aws_iam_role_policy" "core_network_manage" {
  role   = module.execution_roles.apply_execution_role_name
  policy = data.aws_iam_policy_document.core_network_manage.json
}
```

**모듈 통합 옵션:**
- **분리 (권장):** State Bootstrap 모듈과 Execution Role 모듈을 독립적으로 관리
- **통합:** 하나의 모듈로 통합하여 호출 단순화

---

### Tier 2: 구조 동일, 설정값 차이 → 설계 후 모듈화

#### 1. OIDC Broker Role 패턴

**적용:** Github Management 계정 (for_each로 N개 target 관리)

**현재 상태:** 이미 준-모듈화 상태 (for_each 사용)

**코드 위치:**
```
aws-aft-account-customizations/infra-github-management/terraform/iam.tf
```

**모듈화 필요성:** 낮음 (현재 구조로 충분히 관리 가능)

---

#### 2. RAM Share 패턴

**적용 예상:** 3~4개
- Core Network: TGW Share (CN-08)
- Core Network: Resolver Rule Share (CN-12)
- 기타 공유 리소스

**모듈화 복잡도:** 중간
- 공유 대상 리소스 타입이 다양 (TGW, Resolver Rule, Subnet 등)
- 범용 모듈 설계 시 추상화 수준 결정 필요

---

#### 3. VPC Foundation 패턴

**적용 예상:** 10개 이상
- Core Platform VPC (CN-04)
- Ingress/Egress VPC (PM-03, PM-04)
- Runner VPC (GH-05)
- Workload VPC (향후 수십 개)

**모듈화 복잡도:** 높음
- CIDR, AZ 수, Subnet 배치 전략이 계정 유형별로 다름
- 표준 모듈 + 변수 기반 커스터마이징 필요

**우선순위:** Workload 계정 온보딩 시작 시점에 맞춰 Phase 3에서 진행

---

### Tier 3: 고유 로직 → 모듈화 불필요

| 카테고리 | 대표 Task | 이유 |
|---------|----------|------|
| Control Tower 관리 | MGT-02~06 | Management 계정에만 존재, 반복 없음 |
| GitHub Runner 인프라 | GH-05~11 | GitHub Management에만 존재, 복잡한 고유 로직 |
| AFT 엔진 | AFT-01~07 | AFT Management에만 존재, upstream 모듈 사용 |
| OU 자동화 | OU-03~08 | OU Management 고유 YAML 기반 로직 |
| 보안 서비스 위임 설정 | SEC-03~12 | Security Tooling 고유, 각 서비스마다 API 다름 |
| 도메인 특화 인프라 | CN-05~16 (TGW, IPAM) | 네트워크 토폴로지는 조직별로 고유 |
| 로그 수집 정책 | LOG-03~10 | Log Archive 고유, S3 Bucket Policy 패턴 |
| 위임 수신 | SEC-03, AUD-03 등 | Management 계정에서 Manual/API 실행 |

---

### Tier 분류 요약

| Tier | 모듈 후보 | 적용 계정 수 | 총 코드 중복 예상 | 모듈화 효과 | 권장 시기 |
|------|----------|------------|----------------|----------|----------|
| **Tier 1** | State Bootstrap | 9개 | ~900 LOC | 신규 계정 온보딩 80% 단축, 보안 표준 강제 | Phase 1 (즉시) |
| **Tier 1** | Execution Role Pair | 9개 | ~720 LOC | 권한 표준화, Cross-Account 접근 구조 통일 | Phase 1 (즉시) |
| **Tier 2** | OIDC Broker Role | 1개 (for_each) | - | 명시적 인터페이스 분리 가능 | Phase 2 (선택) |
| **Tier 2** | RAM Share | 3~4개 | ~150 LOC | 공유 리소스 관리 표준화 | Phase 2 (중기) |
| **Tier 2** | VPC Foundation | 10개+ | 예상 ~500 LOC | Workload VPC 생성 자동화 | Phase 3 (Workload 온보딩 시) |
| **Tier 3** | 나머지 | - | - | 모듈화 불필요 (고유 로직) | - |

---

## 5. 권장 로드맵

### Phase 1: 즉시 (현재 ~ 2개월)

**목표:** Tier 1 모듈 추출 및 적용

**작업 항목:**
1. State Bootstrap 모듈 생성
   - 기존 코드 중 공통 부분 추출
   - 변수 인터페이스 설계
   - Git Tag 기반 버전 관리 (v1.0.0)
   
2. Execution Role Pair 모듈 생성
   - Trust Policy 표준화
   - 도메인 정책 부착 가이드 작성
   
3. 기존 4개 계정에 모듈 적용 (Pilot)
   - Core Network, Perimeter, Identity Center Management, OU Management
   - 모듈 안정성 검증
   
4. 계획 중인 5개 계정 생성 시 모듈 적용
   - Security Tooling, Break Glass, Backup, Observability, CICD

**예상 효과:**
- 코드 중복 1,620 LOC 제거
- 신규 계정 온보딩 시간 4시간 → 1시간 단축

---

### Phase 2: 단기 (2~4개월)

**목표:** Tier 2 중 효과 높은 항목 모듈화

**작업 항목:**
1. RAM Share 모듈 생성 (선택)
   - TGW, Resolver Rule, Subnet 등 공유 리소스 타입별 검토
   - 범용 모듈 vs 타입별 모듈 결정
   
2. OIDC Broker Role 명시적 모듈 분리 (선택)
   - 현재 for_each 구조로 충분하지만, 외부 참조 시 모듈로 분리 고려

**예상 효과:**
- 공유 리소스 관리 표준화
- 신규 Target 계정 추가 시 일관성 보장

---

### Phase 3: 중기 (4~6개월, Workload 온보딩 시작 시점)

**목표:** Workload 계정 온보딩 대비 VPC Foundation 모듈

**작업 항목:**
1. VPC Foundation 모듈 설계
   - 표준 VPC 구조 정의 (3-tier, 2-tier, single-tier)
   - CIDR 자동 할당 (IPAM 연동)
   - TGW Attachment 자동화
   
2. Workload 계정 유형별 템플릿 생성
   - Web Application VPC
   - Database VPC
   - Container VPC (ECS/EKS)
   
3. Pilot 적용 (1~2개 그룹사)

**예상 효과:**
- Workload VPC 생성 시간 8시간 → 2시간 단축
- 네트워크 표준 준수율 100%

---

## 6. 후속 확인 사항

### 모듈 저장소 구조
- [ ] 중앙 Terraform 모듈 저장소 생성 위치 결정 (별도 repo vs monorepo)
- [ ] 모듈 버전 관리 정책 수립 (Semantic Versioning 적용)
- [ ] 모듈 릴리즈 프로세스 정의 (PR 검증, 승인 권한)

### 모듈 적용 정책
- [ ] 기존 계정에 모듈 적용 시 마이그레이션 전략 (Blue/Green vs In-place)
- [ ] 모듈 버전 업그레이드 강제 여부 (전사 통일 vs 계정별 선택)
- [ ] 모듈 미사용 계정에 대한 예외 처리 규칙

### 거버넌스
- [ ] 모듈 소유팀 지정 (Platform 팀 vs Security 팀 협업)
- [ ] 모듈 변경 시 영향받는 계정 알림 방법
- [ ] 모듈 보안 취약점 발견 시 긴급 패치 프로세스

### 기술적 검증
- [ ] State Bootstrap 모듈의 S3 Backend 순환 참조 방지 방법 (Bootstrap State는 어디에?)
- [ ] Execution Role 모듈 적용 시 기존 역할과의 호환성 검증
- [ ] 모듈 적용 후 Terraform State 이관 필요 여부

### 문서화
- [ ] 모듈 사용 가이드 작성 (README, 예제 코드)
- [ ] 모듈화 전후 비교 문서 (Before/After)
- [ ] 트러블슈팅 가이드 (자주 발생하는 오류 및 해결 방법)

---

## 용어 설명 (Glossary)

- **AFT (Account Factory for Terraform)**: AWS Control Tower 환경에서 Terraform을 이용한 계정 자동 생성 및 커스터마이징 프레임워크
- **Baseline**: 계정 생성 시 자동으로 적용되는 최소 보안/운영 설정
- **Blast Radius**: 장애 또는 변경의 영향 범위
- **Broker Role**: GitHub Actions에서 OIDC 인증 후 Target 계정의 Execution Role을 assume하기 위한 중간 역할
- **Delegated Administrator**: 특정 AWS 서비스를 관리할 권한을 위임받은 계정
- **Execution Role**: Terraform이 실제로 AWS 리소스를 생성/수정하기 위해 assume하는 역할
- **IPAM (IP Address Manager)**: AWS VPC의 IP 주소 할당을 중앙에서 관리하는 서비스
- **OIDC (OpenID Connect)**: GitHub Actions와 AWS 간 임시 자격 증명 교환을 위한 인증 프로토콜
- **OU (Organizational Unit)**: AWS Organizations에서 계정을 그룹화하는 논리적 단위
- **RAM (Resource Access Manager)**: AWS 리소스를 계정 간 공유하기 위한 서비스
- **SCP (Service Control Policy)**: OU 또는 계정에 부착되어 허용/거부 권한을 제어하는 정책
- **State Bootstrap**: Terraform State를 저장할 S3 Bucket 및 KMS Key를 생성하는 초기 설정
- **TGW (Transit Gateway)**: 여러 VPC와 온프레미스 네트워크를 연결하는 중앙 라우팅 허브
- **Tier**: 모듈화 적합성에 따른 분류 (Tier 1: 즉시 모듈화, Tier 2: 설계 후 모듈화, Tier 3: 모듈화 불필요)
- **Trusted Access**: AWS 서비스가 Organizations API에 접근할 수 있도록 허용하는 설정
