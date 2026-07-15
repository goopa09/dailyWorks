#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)
BRANCH="tasks/${TODAY}"

cd "$REPO_DIR"

# ── 1. 오늘 일지 파일 존재 확인 ──────────────────────────────────────────────
if [[ ! -f "${TODAY}.md" ]]; then
  echo "오류: ${TODAY}.md 파일이 없습니다. morning-start.sh를 먼저 실행했는지 확인하세요."
  exit 1
fi

# ── 2. 브랜치 확인 및 체크아웃 ───────────────────────────────────────────────
echo "==> [1/5] 브랜치 체크아웃: ${BRANCH}"
if git show-ref --quiet "refs/heads/${BRANCH}"; then
  git checkout "${BRANCH}"
else
  echo "오류: 브랜치 '${BRANCH}'가 없습니다. morning-start.sh를 먼저 실행하세요."
  exit 1
fi

# ── 3. 오늘 수행한 업무 파싱 ─────────────────────────────────────────────────
# '오늘의 주요 업무 (To-Do)' 섹션에서 완료된 항목([x]) 추출
DONE_TASKS=$(grep -E '^\s*-\s*\[x\]' "${TODAY}.md" | sed 's/^\s*-\s*\[x\]\s*/- /' || true)

if [[ -z "$DONE_TASKS" ]]; then
  # 완료 표시가 없으면 전체 To-Do 항목을 그대로 사용
  DONE_TASKS=$(awk '/## 🎯 오늘의 주요 업무 \(To-Do\)/{found=1; next} found && /^---/{exit} found && /^\s*-/{print}' "${TODAY}.md" || true)
fi

if [[ -z "$DONE_TASKS" ]]; then
  DONE_TASKS="- (업무 내용 없음)"
fi

# ── 4. git add & commit ───────────────────────────────────────────────────────
echo ""
echo "==> [2/5] 변경 파일 스테이징"
git add "${TODAY}.md"

# 다른 변경된 파일도 있으면 함께 추가
if [[ -n "$(git status --porcelain)" ]]; then
  git add -u
fi

COMMIT_MSG="업무일지 정리 - ${TODAY}

${TODAY}.md 파일에 '오늘의 주요 업무 (To-Do)' 아래 수행한 업무를 정리

${DONE_TASKS}"

echo ""
echo "==> [3/5] 커밋"
echo "    커밋 메시지:"
echo "---"
echo "$COMMIT_MSG"
echo "---"
git commit -m "$COMMIT_MSG"

# ── 5. git push ───────────────────────────────────────────────────────────────
echo ""
echo "==> [4/5] 원격 push: origin/${BRANCH}"
git push -u origin "${BRANCH}"

# ── 6. PR 생성 및 merge ───────────────────────────────────────────────────────
echo ""
echo "==> [5/5] PR 생성 및 merge"

PR_TITLE="TASKS: 일일 업무 일지 - ${TODAY}"
PR_BODY="## 업무 요약

${DONE_TASKS}

## 변경 파일
- \`${TODAY}.md\`"

# PR이 이미 존재하는지 확인
EXISTING_PR=$(gh pr list --head "${BRANCH}" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [[ -n "$EXISTING_PR" ]]; then
  echo "    기존 PR #${EXISTING_PR} 발견. merge를 진행합니다."
  PR_NUMBER="$EXISTING_PR"
else
  echo "    PR 생성 중..."
  PR_URL=$(gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base main \
    --head "${BRANCH}")
  echo "    PR 생성 완료: ${PR_URL}"
  PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')
fi

echo "    PR #${PR_NUMBER} merge 중..."
gh pr merge "${PR_NUMBER}" --merge --delete-branch

echo ""
echo "완료! 오늘 하루도 수고하셨습니다 :)"
