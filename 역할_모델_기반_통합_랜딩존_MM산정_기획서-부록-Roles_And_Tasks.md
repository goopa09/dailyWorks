# 한진그룹 AWS 랜딩존 운영 역할·업무 전체 카탈로그

## 문서 목적 및 배경

본 문서는 한진그룹 AWS 랜딩존 운영 조직 확정을 위한 의사결정 참고 자료이다.
**어떤 Ops Group이 어떤 업무를 수행하며, 해당 업무가 MSP A / MSP B 중 어디에 귀속되는가**를 명확히 정의한다.

### 운영 참여 주체

| 주체 | 역할 | 설명 |
|------|------|------|
| **한진칼** | LZ Owner | 랜딩존 소유자. 정책 승인, 예외 최종 승인, 비용 분쟁 조정 등 Owner 권한 행사 |
| **그룹사** | 랜딩존 고객 | 랜딩존을 통해 AWS 환경을 사용하는 계열사 |
| **MSP A** | 주 운영 업체 | 플랫폼·거버넌스와 같은 랜딩존 코어 영역 및 Workload 담당|
| **MSP B** | A사 협력 업체 | 보안 및 Workload 담당 |
| **GICC** | 보안관제 센터 (독립 조직) | 24/7 보안 이벤트 관제(Blue Team) + Findings 분석·조치 요청(내부 Purple Team). MSP와 별도 조직이며 MM 산정 제외 |
> 2개 MSP가 각자의 영역을 책임지고 Workload 운영은 분담합니다. GICC는 그룹 차원의 보안관제를 전담하는 독립 조직입니다.

### 확정 운영 팀 (3개)

| 운영 팀 | 담당 도메인 | 주 MSP |
|---------|-----------|--------|
| Core Infra Ops Group | PLT · NET · IAC · GOV · OPS | MSP-A |
| Security Ops Group | SEC · IAM | MSP-B |
| Workload Ops Group | WLK | MSP-A/B (Workload Infra Eng) + TBD (DBA) |

---

## 범례

> **용어 구분**: 본 문서에서 "Account"는 AWS Organizations 내 멤버 계정(AWS Account)을 의미한다. IAM 사용자(IAM User)나 Identity Center 접근 권한과는 구분된다.

### 업무 유형

| 유형 코드 | 설명 |
|-----------|------|
| `상시-일` | 매일 수행하는 정기 운영 업무 |
| `상시-주` | 주 1회 수행하는 정기 운영 업무 |
| `상시-월` | 월 1회 수행하는 정기 운영 업무 |
| `상시-분기` | 분기 1회 수행하는 정기 운영 업무 |
| `상시-연` | 연 1회 수행하는 정기 운영 업무 |
| `이벤트-온보딩` | 신규 그룹사·워크로드 온보딩 시 발생 |
| `이벤트-변경` | 인프라·정책·권한 변경 요청 시 발생 |
| `이벤트-인시던트` | 장애·보안 이벤트·이상 탐지 시 발생 |
| `이벤트-운영전환` | AWS Account 폐기·DB 마이그레이션 등 서비스 전환 시 발생 |
| `이벤트-거버넌스` | ADR 작성·정책 예외 승인·감사 대응 등 거버넌스 이벤트 |

### MSP 귀속 기준

| 구분 | 기준 |
|------|------|
| `MSP-A` | 랜딩존 플랫폼·거버넌스 업무 + Workload 운영 |
| `MSP-B` | 보안 운영·IAM + Workload 운영 |
| `A+B` | 두 업체가 협력해야 하는 이벤트성 업무 (온보딩, 인시던트, DB 마이그레이션 등) |
| `한진칼` | 정책 승인, 예외 최종 승인, 비용 분쟁 조정 등 Owner 권한 행사 |
| `GICC` | 보안관제 (24/7 모니터링, Findings 분석) — **독립 조직, MM 산정 제외** |

> **주의**: `DBA`는 TBD로 의사 결정이 필요합니다. `GICC`는 MSP-A, MSP-B와는 별도의 그룹 차원 보안 조직입니다.

### 역할자 목록

| 역할자 | 운영 팀 | MSP 귀속 | 담당 도메인 | 주요 담당 영역 |
|--------|---------|----------|------------|--------------|
| Platform Eng | Core Infra Ops Group | MSP-A | PLT | Control Tower, AFT, OU/Account 구조 |
| Network Eng | Core Infra Ops Group | MSP-A | NET | TGW, NFW, Direct Connect, Route 53, VPC |
| IaC/DevOps Eng | Core Infra Ops Group | MSP-A | IAC | Terraform, GitHub Actions, Policy-as-Code |
| Governance Analyst | Core Infra Ops Group | MSP-A | GOV | 네이밍·태깅 정책, ADR, 거버넌스 표준 |
| FinOps Analyst | Core Infra Ops Group | MSP-A | GOV | 비용 정산·배분·최적화 |
| Cloud Ops | Core Infra Ops Group | MSP-A | OPS | 랜딩존 모니터링, 티켓 대응, 운영 가이드 |
| Onboarding Eng | Core Infra Ops Group | MSP-A+B | OPS | 그룹사 온보딩 조율 |
| Security Ops | Security Ops Group | MSP-B | SEC | SCP, GuardDuty, Security Hub, Config |
| IAM/Identity Eng | Security Ops Group | MSP-B | IAM | Identity Center, Permission Set, Break Glass |
| Workload Infra Eng | Workload Ops Group | MSP-A/B | WLK | EKS/ECS, CI/CD, 워크로드 플랫폼 |
| DBA | Workload Ops Group | **TBD** | WLK | 워크로드 DB 후선 지원 (이슈·구성·마이그레이션·아키텍처 리뷰) |

> A+B 는 협업, A/B 는 (그룹사, 어카운트) 분리 책임 운영

---

## Ops Group별 업무 카탈로그

### Core Infra Ops Group

Core Infra Ops Group은 랜딩존 플랫폼·네트워크·IaC·거버넌스·운영 지원을 담당한다.

#### Platform Eng (MSP-A) — 도메인: PLT

**담당 영역**: Control Tower, AFT, AWS Organizations, OU/Account 구조 운영

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| PLT-001 | AFT 파이프라인 상태 모니터링 | 상시-일 | — | 파이프라인 이상 알림 |
| PLT-002 | Account 벤딩 PR 검토 및 승인 | 상시-일 | IaC/DevOps Eng | PR 승인/반려 기록 |
| PLT-003 | Control Tower Drift 점검 | 상시-월 | — | Drift 점검 리포트 |
| PLT-004 | OU 구조 변경 검토 | 상시-월 | Governance Analyst | OU 변경 검토 의견 |
| PLT-005 | Control Tower 업그레이드 검토 | 상시-반기 | — | 업그레이드 검토 결과 |
| PLT-006 | Account 인벤토리 현행화 | 상시-월 | Cloud Ops | Account 인벤토리 목록 |
| PLT-007 | OU 계층 구조 최적화 리뷰 | 상시-분기 | Governance Analyst | OU 최적화 리뷰 결과 |
| PLT-008 | 플랫폼 ADR 업데이트 | 상시-분기 | Governance Analyst | ADR 문서 |
| PLT-009 | AFT Pipeline 실패 원인 분석 및 재실행 | 이벤트-인시던트 | IaC/DevOps Eng | 장애 분석 보고서 |
| PLT-010 | Control Tower 가드레일 충돌 해소 | 이벤트-인시던트 | Security Ops | 충돌 해소 처리 기록 |
| PLT-011 | Break Glass 긴급 접근 권한 사용 이력 감사 | 이벤트-인시던트 | IAM/Identity Eng, Security Ops | 감사 로그 보고서 |
| PLT-012 | Account Suspend/Close 프로세스 처리 | 이벤트-운영전환 | Governance Analyst, Security Ops | Account 폐기 처리 증적 |

---

#### Network Eng (MSP-A) — 도메인: NET

**담당 영역**: TGW, NFW(Network Firewall), Direct Connect, Route 53, VPC 운영

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| NET-001 | VPC Flow Logs 이상 트래픽 모니터링 | 상시-일 | Cloud Ops | 이상 트래픽 알림 |
| NET-002 | NFW 규칙 위반 탐지 | 상시-일 | Security Ops | NFW 위반 탐지 알림 |
| NET-003 | TGW 라우팅 테이블 일관성 점검 | 상시-월 | — | 라우팅 점검 결과 |
| NET-004 | DNS 해상도 이슈 확인 | 상시-월 | Cloud Ops | DNS 점검 결과 |
| NET-005 | CIDR 대역 사용 현황 업데이트 | 상시-월 | Platform Eng | CIDR 대역 현황표 |
| NET-006 | DX 회선 품질 리포트 | 상시-월 | — | DX 품질 리포트 |
| NET-007 | 네트워크 토폴로지 변경 검토 | 상시-분기 | Platform Eng | 네트워크 토폴로지 문서 |
| NET-008 | 트래픽 패턴 분석 및 최적화 | 상시-분기 | FinOps Analyst | 트래픽 분석 리포트 |
| NET-009 | 그룹사 온프레미스 ↔ AWS 연결 장애 대응 (DX/VPN) | 이벤트-인시던트 | Cloud Ops | 장애 처리 보고서 |
| NET-010 | TGW 라우팅 루프/블랙홀 경로 해소 | 이벤트-인시던트 | Platform Eng | 라우팅 수정 이력 |
| NET-011 | NFW 규칙으로 인한 합법 트래픽 차단 해소 | 이벤트-인시던트 | Security Ops | NFW 규칙 변경 이력 |
| NET-012 | Route 53 Resolver 쿼리 실패 진단 | 이벤트-인시던트 | Cloud Ops | DNS 장애 분석 보고서 |
| NET-013 | 신규 그룹사 VPC CIDR 충돌 검증 | 이벤트-온보딩 | Platform Eng, Onboarding Eng | CIDR 할당 확인서 |

---

#### IaC/DevOps Eng (MSP-A) — 도메인: IAC

**담당 영역**: Terraform 모듈·State 관리, GitHub Actions 파이프라인, Policy-as-Code (Conftest/Checkov)

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| IAC-001 | Terraform Plan 결과 검증 (PR 리뷰) | 상시-일 | Platform Eng | PR 승인/반려 기록 |
| IAC-002 | 파이프라인 실행 상태 모니터링 | 상시-일 | Cloud Ops | 파이프라인 상태 알림 |
| IAC-003 | Conftest/Checkov 정책 업데이트 | 상시-월 | Security Ops | 정책 변경 이력 |
| IAC-004 | Terraform State 파일 상태 점검 | 상시-월 | — | State 점검 결과 |
| IAC-005 | Terraform 모듈 버전 업그레이드 검토 | 상시-월 | Platform Eng | 업그레이드 검토 결과 |
| IAC-006 | Self-Hosted Runner 상태 점검 | 상시-월 | — | Runner 상태 보고 |
| IAC-007 | 모듈 리팩토링 및 IaC 코드 품질 리뷰 | 상시-분기 | Platform Eng | 리팩토링 완료 PR |
| IAC-008 | 불필요 리소스 정리 (IaC 정합성 확보) | 상시-분기 | Cloud Ops | 리소스 정리 이력 |
| IAC-009 | Terraform State Lock 해소 | 이벤트-인시던트 | — | State Lock 해소 기록 |
| IAC-010 | Plan/Apply 실패 원인 분석 및 수정 | 이벤트-인시던트 | Platform Eng | 장애 분석 보고서 |
| IAC-011 | State Drift 탐지 및 코드 반영/Import 처리 | 이벤트-인시던트 | Platform Eng | Drift 처리 이력 |
| IAC-012 | GitHub Actions Self-Hosted Runner 장애 대응 | 이벤트-인시던트 | — | Runner 복구 기록 |
| IAC-013 | Conftest 정책 오탐 수정 | 이벤트-인시던트 | Security Ops | 정책 수정 PR |

---

#### Governance Analyst (MSP-A) — 도메인: GOV (거버넌스)

**담당 영역**: 네이밍·태깅 표준, ADR 관리, 거버넌스 정책 운영

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| GOV-001 | 태깅 정책 위반 리소스 보고 | 상시-주 | Cloud Ops | 태깅 위반 리포트 |
| GOV-007 | 거버넌스 정책 전면 개정 | 상시-연 | Security Ops | 정책 개정 문서 |
| GOV-008 | ADR 아카이빙 및 갱신 | 상시-연 | Platform Eng | ADR 문서 |
| GOV-009 | 태깅 누락 리소스 소유자 추적 | 이벤트-인시던트 | Cloud Ops | 소유자 추적 기록 |
| GOV-011 | 신규 그룹사 CostCenter 코드 부여 | 이벤트-온보딩 | Onboarding Eng | CostCenter 코드 등록 증적 |
| GOV-012 | 신규 그룹사 태그 정책 반영 | 이벤트-온보딩 | IaC/DevOps Eng | 태그 정책 변경 이력 |
| GOV-013 | ADR 신규 작성 (아키텍처 의사결정) | 이벤트-거버넌스 | 관련 도메인 팀 | ADR 문서 |

---

#### FinOps Analyst (MSP-A) — 도메인: GOV (FinOps)

**담당 영역**: 비용 배분·정산·최적화

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| GOV-002 | 비용 이상치 알림 검토 | 상시-주 | Cloud Ops | 이상치 알림 처리 기록 |
| GOV-003 | 그룹사별 AWS 비용 정산 리포트 | 상시-월 | Cloud Ops | 비용 정산 리포트 |
| GOV-004 | Cost Explorer 대시보드 갱신 | 상시-월 | — | 비용 대시보드 |
| GOV-005 | RI/SP(Reserved Instance/Savings Plan) 최적화 검토 | 상시-분기 | — | RI/SP 최적화 권고안 |
| GOV-006 | FinOps 정기 리뷰 | 상시-분기 | Governance Analyst | FinOps 리뷰 보고서 |
| GOV-010 | 예산 초과 원인 분석 및 조치 권고 | 이벤트-인시던트 | Cloud Ops | 비용 초과 분석 보고서 |
| GOV-014 | 비용 배분 정책 예외 처리 | 이벤트-거버넌스 | 한진칼 | 예외 처리 기록 |

---

#### Cloud Ops (MSP-A) — 도메인: OPS

**담당 영역**: 랜딩존 플랫폼 레벨 횡단 운영 (전사 모니터링, 티켓 1차 트리아지, 운영 가이드 관리)

> **Scope**: 본 역할은 랜딩존 플랫폼 레벨의 횡단 운영(전사 모니터링, 티켓 1차 트리아지, 변경관리 프로세스)에 한정한다. 워크로드 인프라 자체의 운영(EKS/ECS, DB 등)은 Workload Ops Group을 참조한다.

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| OPS-001 | CloudWatch 대시보드 이상 지표 확인 | 상시-일 | — | 이상 지표 알림 |
| OPS-002 | 지원 티켓 처리 (1차 트리아지) | 상시-일 | 관련 도메인 팀 | 티켓 처리 기록 |
| OPS-003 | 그룹사 운영 현황 리포트 | 상시-주 | — | 운영 현황 리포트 |
| OPS-005 | 운영 가이드 문서 현행화 | 상시-월 | 관련 도메인 팀 | 운영 가이드 문서 |
| OPS-006 | SLA 준수 현황 집계 | 상시-월 | — | SLA 리포트 |
| OPS-007 | 그룹사 만족도 조사 | 상시-분기 | — | 만족도 조사 결과 |
| OPS-008 | 교육 자료 갱신 | 상시-분기 | 관련 도메인 팀 | 교육 자료 |
| OPS-010 | 그룹사 Permission Set 접근 오류 1차 지원 | 이벤트-인시던트 | IAM/Identity Eng | 1차 지원 기록 |
| OPS-011 | AWS 서비스 장애 시 그룹사 공지 및 상황 전파 | 이벤트-인시던트 | — | 장애 공지 기록 |
| OPS-012 | 운영 가이드 미비 시 임시 절차서 작성 | 이벤트-운영전환 | 관련 도메인 팀 | 임시 절차서 |
| OPS-013 | 변경 관리 프로세스 조율 (변경 요청 접수 → 완료 통보) | 이벤트-변경 | IaC/DevOps Eng, 관련 도메인 팀 | 변경 완료 통보 기록 |

---

#### Onboarding Eng (MSP-A+B) — 도메인: OPS

**담당 영역**: 그룹사 온보딩 조율

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| OPS-004 | 온보딩 요청 처리 및 현황 관리 | 상시-주 | Platform Eng | 온보딩 요청 처리 기록 |
| OPS-009 | 신규 그룹사 Account 온보딩 조율 | 이벤트-온보딩 | Platform Eng, Network Eng, Security Ops, IAM/Identity Eng | 온보딩 완료 보고서 |

---

### GICC (보안관제 센터) — 독립 조직

**담당 영역**: 24/7 보안 이벤트 관제(보안관제 팀) + Findings 분석·조치 요청(Purple Team)

> GICC는 한진그룹 통합 보안관제 센터로, 관제 팀(이벤트 탐지·긴급 차단)과 내부 Purple Team(Findings 분석·조치 요청)으로 구성된다. MSP-A, MSP-B와는 별개의 독립 조직이며, **MM 산정 대상에서 제외**된다.

| 업무 ID | 업무명 | 업무 유형 | 팀 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----|-----------|------------|
| GICC-001 | GuardDuty Finding 실시간 모니터링 | 상시-일 | 보안관제 | Security Ops | Finding 탐지 알림 |
| GICC-002 | Security Hub 알림 1차 트리아지 | 상시-일 | 보안관제 | Security Ops | 트리아지 분류 기록 |
| GICC-003 | 보안 이벤트 탐지 및 초기 분류 | 이벤트-인시던트 | 보안관제 | Security Ops, Network Eng, Platform Eng | 보안 이벤트 탐지 보고서 |
| GICC-004 | 보안 정책 준수 현황 모니터링 | 상시-주 | 보안관제 | Security Ops | 정책 준수 모니터링 결과 |
| GICC-005 | Findings 상세 분석 및 오탐·정탐 판단 | 이벤트-인시던트 | Purple Team | Security Ops | 분석 보고서, 오탐·정탐 판정 |
| GICC-006 | 조치 요청 티켓 생성 및 탐지 기준 개선 | 이벤트-인시던트 | Purple Team | Security Ops | 조치 요청 티켓, 탐지 룰 변경 이력 |

> **참고**: GICC 업무는 그룹 차원의 보안관제 조직이 수행하므로 랜딩존 운영 MM 산정에 포함하지 않는다.

---

### Security Ops Group

Security Ops Group은 보안 정책·모니터링 및 IAM/Identity 관리를 담당한다.

#### Security Ops (MSP-B) — 도메인: SEC

**담당 영역**: 보안 서비스 설정 변경·조치 수행 (GICC Purple Team 조치 요청 접수 후 실행), SCP·Config 운영

> **역할 구분**: GICC 보안관제가 이벤트를 탐지하고, Purple Team이 Findings를 분석해 조치를 요청하면, Security Ops가 실제 AWS 설정 변경·조치를 수행한다. ISMS 인증심사 대응은 한진칼 담당자가 주관하나 증적 수집·기술 항목 대응 등 실무를 Security Ops가 수행한다.

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| SEC-001 | Security Hub 조치 요청 접수 및 처리 | 상시-일 | **GICC Purple Team** (조치 요청), Security Ops (실행) | 조치 처리 기록 |
| SEC-002 | GuardDuty Finding 조치 수행 | 상시-일 | **GICC** (관제·분석), Security Ops (실행) | Finding 처리 기록 |
| SEC-003 | SCP 정책 효과 검증 | 상시-주 | Platform Eng | SCP 효과 검증 결과 |
| SEC-004 | Config Non-Compliant 리소스 추적 | 상시-주 | Cloud Ops | 비준수 리소스 목록 |
| SEC-005 | Permission Set 접근 권한 인증 (Access Certification) | 상시-월 | IAM/Identity Eng | 권한 인증 결과 |
| SEC-006 | IAM Access Key 만료 관리 | 상시-월 | IAM/Identity Eng | 만료 키 처리 목록 |
| SEC-007 | SCP 전면 리뷰 | 상시-분기 | Platform Eng, Governance Analyst | SCP 리뷰 보고서 |
| SEC-008 | Conformance Pack 업데이트 | 상시-분기 | IaC/DevOps Eng | Conformance Pack 변경 이력 |
| SEC-009 | 보안 감사 보고서 작성 | 상시-분기 | Governance Analyst | 보안 감사 보고서 |
| SEC-010 | 보안 인시던트 조치 수행 (GICC 탐지·분석 → Security Ops 실행) | 이벤트-인시던트 | **GICC** (탐지·Purple Team 분석 및 조치 요청), Network Eng, Platform Eng, Cloud Ops | 인시던트 대응 보고서 |
| SEC-011 | SCP 적용 오류로 인한 서비스 차단 해소 | 이벤트-인시던트 | Platform Eng, IaC/DevOps Eng | SCP 변경 이력 |
| SEC-012 | IdP (Google Workspace SCIM) 동기화 오류 처리 | 이벤트-인시던트 | IAM/Identity Eng | IdP 동기화 복구 기록 |
| SEC-013 | **ISMS 인증심사 대응** | 상시-연 | IAM/Identity Eng, Governance Analyst, 한진칼 | ISMS 심사 대응 증적, 인증 완료 보고서 |

---

#### IAM/Identity Eng (MSP-B) — 도메인: IAM

**담당 영역**: IAM Identity Center, Permission Set, IdP 연동, Break Glass 관리

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| IAM-001 | IAM Identity Center 일일 접속 현황 확인 | 상시-일 | Cloud Ops | 접속 현황 알림 |
| IAM-002 | Permission Set 사용 현황 점검 | 상시-주 | — | Permission Set 현황 |
| IAM-003 | Permission Set 접근 권한 인증 지원 | 상시-월 | Security Ops | 권한 인증 결과 |
| IAM-004 | 전사 Permission Set 구성 리뷰 | 상시-분기 | Security Ops, Governance Analyst | Permission Set 리뷰 보고서 |
| IAM-005 | IAM Identity Center 접속 장애 대응 | 이벤트-인시던트 | Cloud Ops | 장애 처리 보고서 |
| IAM-006 | Break Glass 긴급 접근 권한 사용 사후 감사 | 이벤트-인시던트 | Security Ops, Platform Eng | Break Glass 감사 보고서 |
| IAM-007 | 신규 그룹사 IdP 그룹/Permission Set 설계 | 이벤트-온보딩 | Security Ops, Onboarding Eng | Permission Set 설계서 |
| IAM-008 | Permission Set 신규 생성/수정 처리 | 이벤트-변경 | IaC/DevOps Eng | IaC PR, 변경 이력 |
| IAM-009 | IAM 권한 요청 검토 및 승인 | 이벤트-거버넌스 | Security Ops | 권한 요청 처리 기록 |
| IAM-010 | SCP 예외 요청 검토 및 등록 | 이벤트-거버넌스 | Security Ops, 한진칼 | 예외 등록 기록 |

---

### Workload Ops Group

Workload Ops Group은 워크로드 컨테이너 인프라 및 DB 운영을 담당한다.

#### Workload Infra Eng (MSP-A/B) — 도메인: WLK

**담당 영역**: EKS/ECS 클러스터, 워크로드 CI/CD, 컨테이너 플랫폼

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| WLK-001 | EKS/ECS 클러스터 상태 모니터링 | 상시-일 | Cloud Ops | 클러스터 이상 알림 |
| WLK-002 | 파드/태스크 이상 탐지 및 조치 | 상시-일 | Cloud Ops | 이상 처리 기록 |
| WLK-003 | 워크로드 CI/CD 파이프라인 상태 점검 | 상시-주 | IaC/DevOps Eng | 파이프라인 점검 결과 |
| WLK-004 | 컨테이너 이미지 취약점 스캔 | 상시-주 | Security Ops | 취약점 스캔 리포트 |
| WLK-005 | EKS 노드 그룹 패치/업그레이드 검토 | 상시-월 | Platform Eng | 패치 검토 결과 |
| WLK-006 | 워크로드 리소스 사용률 리포트 | 상시-월 | FinOps Analyst | 사용률 리포트 |
| WLK-007 | EKS 버전 업그레이드 계획 수립 | 상시-분기 | Platform Eng | 업그레이드 계획서 |
| WLK-008 | 워크로드 인프라 아키텍처 리뷰 | 상시-분기 | Platform Eng, Security Ops | 아키텍처 리뷰 결과 |
| WLK-009 | 워크로드 서비스 장애 초기 대응 및 에스컬레이션 | 이벤트-인시던트 | DBA, Cloud Ops, Network Eng | 장애 처리 보고서 |
| WLK-010 | 신규 워크로드 온보딩 (네임스페이스, RBAC, 네트워크 정책) | 이벤트-온보딩 | IAM/Identity Eng, Network Eng | 온보딩 완료 증적 |
| WLK-011 | 워크로드 인프라 변경 요청 처리 (스케일링, 네트워크 정책 등) | 이벤트-변경 | IaC/DevOps Eng | 변경 처리 이력 |

---

#### DBA (TBD) — 도메인: WLK

**담당 영역**: RDS/Aurora DB 후선 지원 (이슈·구성·마이그레이션·아키텍처 리뷰)

> DBA는 Workload Ops Group 소속이나 제공 주체는 MSP-A 또는 MSP-B 중 미결 사항임

| 업무 ID | 업무명 | 업무 유형 | 협력 역할 | 핵심 산출물 |
|---------|--------|-----------|-----------|------------|
| WLK-012 | DB 인스턴스 상태 모니터링 | 상시-일 | Cloud Ops | DB 상태 알림 |
| WLK-013 | 슬로우 쿼리 탐지 및 기록 | 상시-일 | Workload Infra Eng | 슬로우 쿼리 로그 |
| WLK-014 | DB 성능 지표 점검 | 상시-주 | — | DB 성능 점검 결과 |
| WLK-015 | DB 스토리지 사용률 확인 | 상시-주 | Workload Infra Eng | 스토리지 사용 현황 |
| WLK-016 | DB 패치/버전 관리 검토 | 상시-월 | Workload Infra Eng | 패치 관리 이력 |
| WLK-017 | DB 백업 검증 | 상시-월 | — | 백업 검증 결과 |
| WLK-018 | DB 용량 계획 및 최적화 리뷰 | 상시-분기 | FinOps Analyst | DB 용량 계획서 |
| WLK-019 | DB 이슈 후선 지원 (장애·성능 저하) | 이벤트-인시던트 | Workload Infra Eng, Network Eng | DB 이슈 처리 보고서 |
| WLK-020 | DB 구성 변경 지원 (파라미터, 스토리지 확장) | 이벤트-변경 | Workload Infra Eng, IaC/DevOps Eng | DB 구성 변경 이력 |
| WLK-021 | DB 마이그레이션 지원 | 이벤트-운영전환 | Workload Infra Eng (A+B 협력) | 마이그레이션 완료 보고서 |
| WLK-022 | DB 아키텍처 리뷰 | 이벤트-거버넌스 | Workload Infra Eng, Platform Eng | DB 아키텍처 리뷰 결과 |

---

## 업무 통계 요약

### 도메인별 업무 수

| 도메인 | 도메인명 | 상시 업무 | 이벤트 업무 | 소계 |
|--------|----------|-----------|-------------|------|
| PLT | 플랫폼 운영 | 8 | 4 | **12** |
| NET | 네트워크 운영 | 8 | 5 | **13** |
| SEC | 보안 운영 | 10 | 3 | **13** |
| IAM | IAM/Identity 운영 | 4 | 6 | **10** |
| IAC | IaC/DevOps 운영 | 8 | 5 | **13** |
| GOV | 거버넌스/FinOps | 8 | 6 | **14** |
| OPS | Cloud Ops/지원 | 8 | 5 | **13** |
| WLK | Workload 인프라 운영 | 14 | 8 | **22** |
| **합계** | | **68** | **42** | **110** |

### MSP 귀속별 업무 수

| MSP 귀속 | 업무 수 | 비고 |
|----------|---------|------|
| MSP-A | 77 | 플랫폼·거버넌스·IaC 핵심 + Core Infra Ops Group 대부분 |
| MSP-B | 18 | Security Ops Group (SEC + IAM, 보안관제 제외) |
| MSP-A/B | 11 | Workload Infra Eng (그룹사별 분담) |
| TBD | 10 | DBA 업무 (MSP-A/B 미결) |
| A+B | 1 | DB 마이그레이션 지원 (협력) |
| 한진칼 | 1 | 비용 배분 정책 예외 처리 (Owner 권한) |
| **GICC (독립 조직)** | **4** | **보안관제 전담 (MM 산정 제외)** |
| **합계** | **122** | (기존 110 + MSP-B 감소 3건 + GICC 4건 추가 = 122건 전체 업무) |

### 역할별 필요 인력 MM 추정

**산정 기준** (상시 1.5 MM 목표 조정):
- **1 MM = 1 인원(명)** (월 기준 = 20 MD)
- `상시-일`: 약 0.02 MD/건 × 20 영업일 → 월 약 0.02 MM/건
- `상시-주`: 약 0.06 MD/건 × 4회 → 월 약 0.012 MM/건
- `상시-월`: 약 0.3 MD/건 → 월 약 0.015 MM/건
- `상시-반기`: 약 0.25 MD/건 × 2회 → 월 약 0.025 MM/건
- `상시-분기`: 약 0.2 MD/건 × 4회 → 월 약 0.04 MM/건
- `상시-연`: 약 0.3 MD/건 × 1회 → 월 약 0.025 MM/건
- `이벤트`: 평균 발생 빈도와 처리 공수 기반 월 평균 환산 (초기 구축 대비 50% 수준 유지)
- 1 MD = 1 일 기준 (월 20 일)

| 역할자 | MSP 귀속 | 상시 업무 MM | 이벤트 업무 MM (평균) | 합계 MM | 적정 인원 |
|--------|---------|------------|---------------------|---------|---------|
| Platform Eng | MSP-A | 0.19 | 0.15 | **0.3** | 0.3명 |
| Network Eng | MSP-A | 0.18 | 0.15 | **0.3** | 0.3명 |
| IaC/DevOps Eng | MSP-A | 0.18 | 0.2 | **0.4** | 0.4명 |
| Governance Analyst | MSP-A | 0.06 | 0.1 | **0.2** | 0.2명 |
| FinOps Analyst | MSP-A | 0.12 | 0.08 | **0.2** | 0.2명 |
| Cloud Ops | MSP-A | 0.16 | 0.18 | **0.3** | 0.3명 |
| Onboarding Eng | MSP-A+B | 0.01 | 0.12 | **0.1** | 0.1명 |
| Security Ops | MSP-B | 0.20 | 0.1 | **0.3** | 0.3명 |
| IAM/Identity Eng | MSP-B | 0.09 | 0.18 | **0.3** | 0.3명 |
| Workload Infra Eng | MSP-A/B | 0.17 | 0.18 | **0.4** | 0.4명 |
| DBA | TBD | 0.13 | 0.15 | **0.3** | 0.3명 |
| **합계** | | **1.5** | **1.5** | **3.0 MM** | **최소 3명** |

> **참고**: 
> - 이벤트 업무 MM은 기존 유지: 1.5 MM (초기 온보딩 1~2개 그룹사 기준)
> - GICC 보안관제 업무는 그룹 차원 조직이 수행하므로 랜딩존 운영 MM에서 제외됨
> - **전체 필요 인원: 최소 3 MM**
> - **전제 조건**: 높은 수준의 자동화, 효율적 프로세스, 자동 알림/리포트 시스템 필수
> - 사실상 목표수준이고 실제 업무 수행 하면서 현실화 필요

### 온보딩 단계별 인력 MM 확장 계획

**단계 정의** (상시 1.5 MM 기준 재조정):
- **Phase 1 (초기 운영)**: LZ 구축 완료 후 기본 운영 = **3.0 MM (명)** (기본 구성)
- **Phase 1-확장**: 그룹사 6개 온보딩 시 = **약 4.5 MM** (이벤트 업무 100% 증가)
- **Phase 2 (안정 운영)**: 전체 16개 그룹사 온보딩 완료 = **약 6.0 MM** (이벤트 업무 200% 증가)
- **Phase 3 (대안 #3 검토)**: 2027년 이후 독립 거버넌스 확대 시 추가 증원 검토

> **중요**: 본 산정은 높은 수준의 자동화와 효율적인 운영 프로세스를 전제로 함

| 역할자 | 기본 (3.0MM) | Phase 1-확장 (4.5MM) | Phase 2 (6.0MM) | 비고 |
|--------|-----------|----------------|------------|------|
| **Core Infra Ops Group** | | | | |
| Platform Eng | 0.3명 | 0.5명 | 0.7명 | 이벤트 업무 증가 시 단계적 증원 |
| Network Eng | 0.3명 | 0.5명 | 0.7명 | 이벤트 업무 증가 시 단계적 증원 |
| IaC/DevOps Eng | 0.4명 | 0.6명 | 0.8명 | 단계별 +0.2명 |
| Governance Analyst | 0.2명 | 0.3명 | 0.4명 | 정책 관리 확대 |
| Cloud Ops | 0.3명 | 0.5명 | 0.7명 | 모니터링·지원 확대 |
| **Workload Ops Group** | | | | |
| Workload Infra Eng | 0.4명 | 0.7명 | 1명 | 클러스터/Namespace 증가 |
| **Security Ops Group** | | | | |
| Security Ops | 0.3명 | 0.5명 | 0.7명 | 보안 정책 운영 |
| IAM/Identity Eng | 0.3명 | 0.4명 | 0.6명 | Compliance 강화 |
| **기타** | | | | |
| DBA | 0.3명 | 0.5명 | 0.7명 | DB 운영 규모 증가 |
| Onboarding Eng | 0.1명 | 0.3명 | 0.4명 | 온보딩 빈도 증가 |
| FinOps Analyst | 0.2명 | 0.3명 | 0.4명 | 비용 운영 확대 |
| **합계** | **3.0 MM** | **4.5 MM** | **6.0 MM** | 단계별 증원 계획 |

**확장 전략 설명**:
- **기본 → Phase 1-확장**: 총 +1.5 MM (이벤트 업무 100% 증가 대응)
- **Phase 1-확장 → Phase 2**: 총 +1.5 MM (이벤트 업무 추가 증가)
- 증원 트리거: 그룹사 온보딩 확정 시점 기준 2개월 전 선제 채용 권장
- 초기 3.0 MM은 핵심 역할자만으로 구성 가능한 린 체계
- **전제 조건 필수**: 높은 수준의 자동화, 효율적 프로세스, 자동 알림/리포트 시스템

> **참고**: 메인 문서 "역할_모델_기반_통합_랜딩존_MM산정_기획서.md" 참조

---

## 참고

- 본 문서의 MSP 귀속은 **DBA 귀속(MSP-A/B 미결 포함)** 한진칼 의사결정 회의에서 최종 확정된다.
- **GICC 보안관제 업무**: GICC-001~004 업무는 그룹 차원의 보안관제 센터가 수행하므로 랜딩존 운영 MM 산정에서 제외됨. GICC와 Security Ops Group의 협력 프로세스는 별도 문서 참조.
- **추가 검토 필요**:
  - Security Ops Group 역할 범위 및 보안 업무 경계: [`운영_역할_업무_카탈로그__Security_Ops_Group_역할_범위_검토.md`](./운영_역할_업무_카탈로그__Security_Ops_Group_역할_범위_검토.md)
  - Workload 인프라 운영의 MSP-A/B 분담 방식: [`운영_역할_업무_카탈로그__Workload_분담_검토.md`](./운영_역할_업무_카탈로그__Workload_분담_검토.md)
  - GICC와 Security Ops의 협력 프로세스: 별도 문서 작성 예정
- 운영 이벤트 분류 체계는 `랜딩존_운영_이벤트_개념_초안.md` 참조.
- IAM 권한 요청·예외 처리 절차는 `AWS_IAM_권한_요청_운영_절차서.md` 및 `AWS_IAM_권한_예외_및_Break-glass_관리_절차서.md` 참조.
