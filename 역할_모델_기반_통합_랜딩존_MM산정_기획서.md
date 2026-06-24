# 한진그룹 통합 AWS Landing Zone 운영 조직 및 인력 분석

## 분석 전제

본 문서는 AWS Landing Zone 구축 프로젝트 산출물(ADR, 설계 문서 등)을 기반으로, 안정적인 운영을 위해 필요한 운영 조직 구조, 인력 규모를 정의한다.

| 항목 | 내용 |
|------|------|
| 대상 규모 | 약 16개 그룹사, 25개+ 계정 (확장 예정) |
| 핵심 기술 | Control Tower + AFT, Terraform, GitHub Actions, TGW/NFW, IAM Identity Center |
| 운영 모델 | 중앙 집중형 거버넌스 + 그룹사 자율 운영 |
| 운영 조직 형태 | MSP-A + MSP-B 분담 운영 |
| 역할 그룹 모델 | ADR-010: 운영 책임 분리 + 핵심 거버넌스 보완 모델 (대안 #2) |

---

## 운영 조직 구조

ADR-010 역할 그룹 모델에 따라 구성하되, **MM 산정 대상은 3개 Ops Group**만 포함한다.
한 명이 여러 업무를 담당하는 겸직 구조로 설계하여 효율성을 극대화한다.

```
한진그룹 Cloud Platform 총괄
│
├── Core Infra Ops Group (~1.8 MM)            ← [MM 산정 대상] — MSP-A
│   ├── Platform Eng                          (Control Tower, AFT, OU/계정)
│   ├── Network Eng                           (TGW, NFW, DX, VPC)
│   ├── IaC/DevOps Eng                        (Terraform, GitHub Actions)
│   ├── Governance Analyst                    (정책, 태깅)
│   ├── FinOps Analyst                        (비용 운영)
│   ├── Cloud Ops                             (운영 지원, 모니터링)
│   └── Onboarding Eng                        (그룹사 온보딩 조율)
│
├── Workload Ops Group (~0.7 MM)              ← [MM 산정 대상] — MSP-A/B
│   ├── Workload Infra Eng                    (EKS/ECS, 배포환경)
│   └── DBA                                   (DB 후선 지원, MSP 귀속 TBD)
│
├── Security Ops Group (~0.6 MM)              ← [MM 산정 대상] — MSP-B (랜딩존 보안 운영 실행)
│   ├── Security Ops                          (보안 서비스 설정·조치)
│   └── IAM/Identity Eng                      (Identity Center, 권한 관리)
│
├── GICC (독립 조직)                          ← [MM 산정 제외]
│   ├── 보안관제                              (24/7 이벤트 관제, 긴급 차단)
│   └── Purple Team                           (Findings 분석, 조치 요청)
│
└── 운영 통제 그룹 (TBD)                      ← 고객사 결정사안 [MM 산정 제외]
    └── 변경관리, 장애대응 조율, 온보딩 지원
```

**MM 산정 대상: 3.0 MM** (최소 3명, 역할별 상세 내역은 부록 Roles_And_Tasks 참조)
- Core Infra Ops Group: ~1.8 MM
- Workload Ops Group: ~0.7 MM (DBA 포함)
- Security Ops Group: ~0.6 MM

---

## Workload 영역 그룹사별 MSP 분리 기준

Workload Infra Eng 업무는 MSP-A와 MSP-B가 그룹사 단위로 분담 운영한다.
분리 기준 및 초기 운영 방향은 아래와 같다.

### 분리 기준 원칙

| 항목 | 내용 |
|------|------|
| **기본 방향** | 그룹사별로 주 담당 MSP를 지정하여 수직적 책임 구조를 유지 |
| **운영 초기** | 초기에는 대상 그룹사가 적고 Core Infra 와의 업무연계 구조 및 수행절차 확립을 위하여 우선 Core Infra를 운영하는 A사가 그룹사 업무를 담당한다. |
| **운영 후기** | 이후 그룹사가 확대되는 시점에 B사의 운영 참여를 논의한다. |

### DBA

DBA(DB 후선 지원)의 MSP 귀속은 지원 업체 선정이 완료될 때까지 **TBD**로 유지한다.

---

## 인력 규모 및 단계별 채용

### Phase 1 — Landing Zone 구축 완료 시 (2026년 8월)

**목표**: 처음 6개 그룹사 온보딩, 기본 운영 체계 수립

**MM 산정 기준**: 역할별 MM 기반 (한 명이 여러 역할 겸임 가능한 린 체계)

| 역할 그룹 | 역할 | MM | 비고 |
|---|---|---|---|
| **Core Infra Ops Group** | Platform Eng (AFT/Control Tower) | 0.3 MM | |
| | Network Eng (TGW, NFW, DX, VPC) | 0.3 MM | |
| | IaC/DevOps Eng (Terraform, GitHub Actions) | 0.4 MM | |
| | Governance Analyst (정책, 태깅) | 0.2 MM | |
| | FinOps Analyst (비용 운영) | 0.2 MM | |
| | Cloud Ops (운영 지원) | 0.3 MM | |
| | Onboarding Eng (온보딩 조율) | 0.1 MM | |
| **Workload Ops Group** | Workload Infra Eng (EKS/ECS) | 0.4 MM | MSP-A/B 각 0.2 MM (초기 50/50 분배, 계약 목적 기준) |
| | DBA | 0.3 MM | MSP 귀속 TBD |
| **Security Ops Group** | Security Ops (SCP, GuardDuty, Security Hub) | 0.3 MM | |
| | IAM/Identity Eng (권한 + 컴플라이언스) | 0.3 MM | |
| **합계** | | **3.0 MM** | **최소 3명** |

> 역할별 상세 MM 산정 내역은 부록 [`역할_모델_기반_통합_랜딩존_MM산정_기획서-부록-Roles_And_Tasks.md`](./역할_모델_기반_통합_랜딩존_MM산정_기획서-부록-Roles_And_Tasks.md) 참조

---


