---
description: Git add를 수행하는 skill
---

# gadd

## Instructions

사용자가 `/gadd` 명령어를 실행하면:

1. `git status`를 실행하여 현재 변경사항을 확인합니다
2. 변경된 파일 목록을 사용자에게 보여줍니다
3. 사용자가 파일 패턴을 지정한 경우 해당 파일들만 add하고, 지정하지 않은 경우 모든 변경사항(`git add -A`)을 add합니다
4. Add 결과를 사용자에게 보고합니다
5. Staged 상태가 된 파일 목록을 보여줍니다

## Usage

```
/gadd [file patterns]
```

예시:
- `/gadd` - 모든 변경사항 추가
- `/gadd *.md` - 마크다운 파일만 추가
- `/gadd 2026-06-25.md` - 특정 파일만 추가
