---
description: Git 브랜치 생성 및 체크아웃을 수행하는 skill
---

# gbranch

## Instructions

사용자가 `/gbranch` 명령어를 실행하면:

1. 현재 브랜치를 확인합니다: `git branch --show-current`
2. 현재 브랜치 상태를 사용자에게 보여줍니다
3. 사용자가 브랜치명을 제공한 경우:
   - 브랜치명이 `tasks/`, `fix/`, `feature/`, `hotfix/`, `docs/` 등의 prefix를 포함하는지 확인합니다
   - prefix가 없으면 적절한 prefix를 제안합니다
   - `git checkout -b [branch-name]`으로 브랜치를 생성하고 전환합니다
4. 사용자가 브랜치명을 제공하지 않은 경우:
   - 어떤 타입의 브랜치를 만들지 물어봅니다 (tasks, fix, feature, hotfix, docs)
   - 브랜치명을 입력받습니다
   - 브랜치를 생성하고 전환합니다
5. 브랜치 생성 결과를 보고합니다
6. 현재 작업 중인 브랜치를 확인시켜줍니다

## Usage

```
/gbranch [branch-name]
```

예시:
- `/gbranch tasks/add-login` - tasks/add-login 브랜치 생성 및 체크아웃
- `/gbranch fix/auth-bug` - fix/auth-bug 브랜치 생성 및 체크아웃
- `/gbranch feature/new-api` - feature/new-api 브랜치 생성 및 체크아웃
- `/gbranch hotfix/security-patch` - hotfix/security-patch 브랜치 생성 및 체크아웃
- `/gbranch docs/update-readme` - docs/update-readme 브랜치 생성 및 체크아웃
- `/gbranch` - 대화형으로 브랜치 생성

## 브랜치 타입

- `tasks/` - 일반 작업, 태스크
- `fix/` - 버그 수정
- `feature/` - 새로운 기능 추가
- `hotfix/` - 긴급 수정
- `docs/` - 문서 작업
