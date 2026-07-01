# Organizations 거버넌스 정책 관리 역할 분리 방안

## 상태
* 2026-06-30 Draft

## 배경

AWS Organizations의 거버넌스 정책(SCP, Tag Policy, Backup Policy, AI Opt-out Policy)은 Management Account에서만 API 호출이 가능하다. 그러나 "정책 내용을 정의하는 역할"과 "정책을 실제로 적용하는 역할"을 분리하여 보안과 거버넌스를 강화할 수 있다.

## 제약 사항

**Organizations API는 Management Account에서만 호출 가능**
- `PutPolicy`, `AttachPolicy`, `CreateOrganizationalUnit` 등의 API는 Management Account 권한 필요
- 다른 계정으로 위임(Delegated Administrator) 불가능

따라서 "정책 적용" 실행은 반드시 Management Account에서 수행해야 함.

## 방안 1: 리포지토리 분리 (코드 소유권 분리)

### 구조
```
[Security 팀 소유 repo: security-policies]
security-policies/
├── scp/
│   ├── deny_root_account.json
│   ├── restrict_regions.json
│   └── enforce_mfa.json
├── tag_policies/
│   └── mandatory_tags.json
└── backup_policies/
    └── daily_backup.json

[Platform 팀 소유 repo: aws-ct-management]
aws-ct-management/organizations/
├── main.tf
│   → security-policies를 참조하여 적용
└── terraform.tfvars
```

### 구현 방법

#### A. Git Submodule 방식
```bash
# aws-ct-management repo에서
git submodule add https://github.com/org/security-policies.git policies/
```

```hcl
# main.tf
resource "aws_organizations_policy" "deny_root" {
  name    = "DenyRootAccount"
  content = file("${path.module}/policies/scp/deny_root_account.json")
  type    = "SERVICE_CONTROL_POLICY"
}
```

#### B. Terraform Module 참조 방식
```hcl
# main.tf
module "security_policies" {
  source = "git::https://github.com/org/security-policies.git//terraform?ref=v1.2.0"
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  policy_id = module.security_policies.deny_root_policy_id
  target_id = var.target_ou_id
}
```

### 장점
- 정책 정의 코드와 적용 코드의 저장소가 물리적으로 분리
- Security 팀이 정책 내용을 독립적으로 관리
- 정책 변경 이력이 별도 repo에 명확히 기록

### 단점
- 두 개의 repo 동기화 필요 (submodule update, module version bump)
- 정책 변경 시 두 repo에 걸친 PR 작업 필요

---

## 방안 2: PR 기반 역할 분리 (프로세스 분리)

### 구조
```
aws-ct-management/organizations/
├── policies/
│   ├── scp/
│   │   ├── deny_root_account.json  ← Security 팀이 작성
│   │   └── restrict_regions.json
│   └── tag_policies/
│       └── mandatory_tags.json
├── main.tf                         ← Platform 팀이 적용
└── CODEOWNERS                      ← 역할별 승인 권한 정의
```

### CODEOWNERS 예시
```
# Security 팀만 정책 내용 수정 가능
/policies/scp/**          @security-team
/policies/tag_policies/** @security-team

# Platform 팀만 Terraform 배포 코드 수정 가능
/main.tf                  @platform-team
/backend.tf               @platform-team

# 정책 적용(attach) 변경은 두 팀 모두 승인 필요
/policy_attachments.tf    @security-team @platform-team
```

### 워크플로우
```
1. Security 팀: policies/scp/new_policy.json 작성 → PR 생성
2. Security Lead: 정책 내용 검토 → 승인
3. Platform 팀: main.tf에서 해당 정책 참조 추가 → PR 생성
4. Platform Lead + Security Lead: 적용 범위 검토 → 승인
5. GitHub Actions: Management Account에서 terraform apply 실행
```

### 장점
- 단일 repo로 관리하여 동기화 문제 없음
- GitHub의 branch protection과 CODEOWNERS로 권한 통제
- PR 기반으로 모든 변경 이력과 승인 기록 보존

### 단점
- 프로세스 준수 여부가 조직 문화에 의존
- CODEOWNERS 룰을 우회할 수 있는 admin 권한자 존재 시 통제 약화

---

## 방안 3: Cross-Account Assume Role

### 구조
```
[Security Tooling Account]
security-governance/
└── terraform/
    ├── main.tf
    │   → Management Account의 OrganizationsAdmin Role을 assume
    └── providers.tf

[Management Account]
└── iam/
    └── cross_account_organizations_admin_role.tf
        → Security Tooling 계정에게 assume 허용
```

### 구현 예시

#### Management Account에서 Role 생성
```hcl
# Management Account: iam/cross_account_role.tf
resource "aws_iam_role" "organizations_admin_for_security" {
  name = "OrganizationsAdminForSecurityTooling"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.security_tooling_account_id}:root"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.external_id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "organizations_full_access" {
  role       = aws_iam_role.organizations_admin_for_security.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess"
}
```

#### Security Tooling Account에서 정책 관리
```hcl
# Security Tooling Account: providers.tf
provider "aws" {
  alias = "management"
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.management_account_id}:role/OrganizationsAdminForSecurityTooling"
    external_id  = var.external_id
    session_name = "SecurityGovernanceSession"
  }
}

# main.tf
resource "aws_organizations_policy" "deny_root" {
  provider = aws.management
  
  name    = "DenyRootAccount"
  content = file("${path.module}/policies/deny_root_account.json")
  type    = "SERVICE_CONTROL_POLICY"
}
```

### 장점
- Security 계정에서 정책 정의부터 적용까지 완전 제어
- Management Account와 Security 계정의 책임 분리가 명확
- Security 팀이 Management Account Terraform에 접근하지 않아도 됨

### 단점
- Cross-account assume role 설정 복잡도 증가
- Management Account에 강력한 권한을 위임하는 role이 존재 (보안 리스크)
- Terraform state가 두 계정에 분산 (Management와 Security Tooling)

---

## 권장 사항

### 초기 단계 (현재)
**방안 2: PR 기반 역할 분리** 권장
- 이유: 구현이 가장 단순하고, 기존 GitHub Actions 파이프라인 활용 가능
- CODEOWNERS + branch protection으로 충분한 통제 가능

### 성숙 단계 (향후)
조직이 커지고 Security 팀의 독립성이 강화되면:
- **방안 3: Cross-Account Assume Role**로 전환 검토
- 단, Management Account의 역할 권한을 세밀하게 제한하는 IAM Policy 설계 필수

---

## 결론

**"정책 정의"와 "정책 적용"의 역할 분리는 가능하나, 실제 API 호출은 Management Account에서 수행**

| 방안 | 소유권 분리 | 구현 복잡도 | 보안 통제 | 권장 시기 |
|------|------------|------------|----------|----------|
| 방안 1: 리포지토리 분리 | 높음 | 중간 | 중간 | 다수의 정책 관리 팀이 있을 때 |
| 방안 2: PR 기반 분리 | 중간 | 낮음 | 중간 | 초기 구축 단계 (권장) |
| 방안 3: Cross-Account Role | 매우 높음 | 높음 | 높음 | 조직 성숙 후 전환 검토 |

## 관련 문서
- ADR-002: IaC 모듈화 전략
- ADR-016: Core Infra pipeline 설계
