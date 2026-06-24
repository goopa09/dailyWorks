---
description: Git push를 수행하는 skill
---

# gpush

## Instructions

사용자가 `/gpush` 명령어를 실행하면:

1. 현재 브랜치를 확인합니다: `git branch --show-current`
2. Unpushed commits가 있는지 확인합니다: `git log origin/$(git branch --show-current)..HEAD --oneline`
3. Push할 commit 목록을 사용자에게 보여줍니다
4. 사용자 확인 후 `git push` 또는 `git push origin [branch]`를 실행합니다
5. Push 결과를 사용자에게 보고합니다

주의: force push가 필요한 경우 사용자에게 명시적으로 확인을 받습니다.

## Usage

```
/gpush [branch name]
```

예시:
- `/gpush` - 현재 브랜치를 push
- `/gpush main` - main 브랜치를 push
