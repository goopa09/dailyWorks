---
description: Git add와 commit을 수행하는 skill
---

# commit

## Instructions

사용자가 `/commit` 명령어를 실행하면:

1. `git status`를 실행하여 변경사항을 확인합니다
2. 변경된 파일 목록을 사용자에게 보여줍니다
3. 사용자가 제공한 commit message가 있으면 그것을 사용하고, 없으면 변경사항을 분석하여 적절한 commit message를 제안합니다
4. 다음 명령어들을 순차적으로 실행합니다:
   ```bash
   git add -A
   git commit -m "commit message"
   ```
5. commit 결과를 사용자에게 보고합니다
6. 필요시 `git push` 여부를 물어봅니다

## Usage

```
/commit [commit message]
```

예시:
- `/commit Add new feature`
- `/commit "Fix bug in authentication"`
