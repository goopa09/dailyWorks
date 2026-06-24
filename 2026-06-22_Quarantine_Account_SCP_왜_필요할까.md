좋은 지적입니다. 실제로 **Control Tower + AFT 환경에서는 "무조건 Quarantine OU를 만들어야 한다"가 정답은 아닙니다.**

오히려 질문하신 것처럼:

> 이미 AFT Account Request 시점에 대상 OU가 정해지고, 해당 OU에는 SCP, Config Rule, Guardrail 등이 적용되어 있는데 왜 또 Quarantine OU가 필요한가?

라는 의문이 충분히 타당합니다.

---

# 먼저 확인해야 할 것

Quarantine SCP가 보호하려는 대상은 사실 OU가 아닙니다.

**"신규 계정 생성 직후 ~ AFT Customization 완료 전"**

구간입니다.

예를 들면

```text
Account 생성
    ↓
OU 이동
    ↓
AWSControlTowerExecutionRole 생성
    ↓
AFT 파이프라인 시작
    ↓
Terraform 실행
    ↓
보안 리소스 생성
```

여기서 AFT가 만드는 것들이 있습니다.

예)

```text
CloudTrail
Config
GuardDuty Membership
IAM Role
SecurityHub
VPC
KMS
S3
```

OU SCP는 이미 적용되어 있지만,

AFT가 만드는 리소스는 아직 없습니다.

---

# 그런데 정말 위험한가?

사실 환경에 따라 다릅니다.

---

## Case 1 : AFT만 계정을 생성 가능

예를 들어

```text
Platform Team
    ↓
AFT Request
    ↓
자동 생성
```

만 허용되고

신규 계정에 접근 가능한 사용자가 아무도 없다면

사실상 Quarantine 필요성이 낮습니다.

---

이 경우

```text
AFT 생성
↓
5~10분 후
↓
Baseline 완료
```

정도이므로

위험도가 크지 않습니다.

---

# AWS도 항상 Quarantine OU를 쓰는 것은 아님

많은 고객 환경이

```text
Account Factory
 ↓
Target OU
 ↓
AFT Baseline
```

만 사용합니다.

특히

* Sandbox
* Development
* 내부 테스트

환경은 더욱 그렇습니다.

---

# Quarantine OU가 등장하는 경우

보통 다음 요구사항이 있을 때입니다.

## 1. 보안 심사 요구

금융권

공공기관

대기업

감사 대응

---

감사인이 묻습니다.

> 계정 생성 직후부터 모든 활동이 통제된다는 증거가 있습니까?

여기에

```text
생성 즉시 Quarantine OU
↓
Deny All SCP
↓
Baseline 완료
↓
OU 이동
```

이 가장 설명하기 쉽습니다.

---

## 2. Baseline 실패 가능성

AFT가 항상 성공하는 것은 아닙니다.

예:

```text
Terraform 실패
```

```text
SecurityHub 생성 실패
```

```text
Provider 에러
```

```text
Git Merge 실수
```

---

그런데 계정은 이미 생성되어 있습니다.

이때

```text
Workloads OU
```

에 바로 들어가 있으면

반쯤 구성된 계정이 남습니다.

---

Quarantine라면

```text
실패
 ↓
계속 격리 상태
```

가 됩니다.

---

## 3. 계정을 즉시 사용하면 안 되는 조직

예:

```text
신규 계정 생성
 ↓
보안팀 승인
 ↓
네트워크 승인
 ↓
비용센터 승인
 ↓
사용 시작
```

같은 프로세스

이 경우 Quarantine이 자연스럽습니다.

---

# 실제로 더 많이 사용하는 방식

최근 AFT 환경에서는 별도 OU 대신

**SCP 자체를 "Quarantine Mode"로 운영**하는 경우가 많습니다.

예:

```text
Workloads OU
```

에 이미 계정 생성

대신

```text
Quarantine SCP
```

를 계정에 직접 Attach

---

```text
Account 생성
 ↓
Workloads OU
 ↓
Quarantine SCP Attach
 ↓
AFT 완료
 ↓
SCP 제거
```

---

장점

* OU 이동 없음
* Account 이동 자동화 없음
* 구조 단순

---

# 개인적으로 현재 AFT 환경이라면

먼저 아래를 확인할 것 같습니다.

### 질문 1

신규 계정에 사람이 로그인 가능한 시점은 언제인가?

---

### 질문 2

AFT 실패 시 계정은 어떻게 처리되는가?

---

### 질문 3

감사 요구사항이 있는가?

---

만약

```text
AFT만 계정 생성 가능
AFT 성공률 높음
감사 요구 없음
```

이라면

솔직히

```text
Quarantine OU
```

까지는 과한 설계일 수 있습니다.

반대로

```text
금융권
감사 대응
계정 생성 후 승인 절차 존재
```

라면

Quarantine OU 방식이 충분히 설득력 있습니다.

그래서 이 업무를 받으셨다면, 바로 SCP를 설계하기보다 먼저 **"우리 조직이 보호하려는 리스크가 정확히 무엇인가?"**를 담당자에게 확인하는 것이 좋습니다. 그 답에 따라 **별도 Quarantine OU**, **계정 단위 Quarantine SCP**, 또는 **아무것도 하지 않는 것**까지 모두 합리적인 결론이 될 수 있습니다.
