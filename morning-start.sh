#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)
BRANCH="tasks/${TODAY}"

cd "$REPO_DIR"

echo "==> [1/3] git 상태 최신화"
git checkout main
git pull

echo ""
echo "==> [2/3] 오늘 브랜치 생성: ${BRANCH}"
if git show-ref --quiet "refs/heads/${BRANCH}"; then
  echo "    브랜치가 이미 존재합니다. 체크아웃만 합니다."
  git checkout "${BRANCH}"
else
  git checkout -b "${BRANCH}"
fi

echo ""
echo "==> [3/3] 오늘 업무 일지 생성: ${TODAY}.md"
if [[ -f "${TODAY}.md" ]]; then
  echo "    ${TODAY}.md 파일이 이미 존재합니다. 건너뜁니다."
else
  LATEST=$(ls [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md 2>/dev/null | sort | tail -n 1)
  if [[ -z "$LATEST" ]]; then
    echo "    복사할 기존 일지 파일이 없습니다."
    exit 1
  fi
  cp "$LATEST" "${TODAY}.md"
  echo "    ${LATEST} → ${TODAY}.md 복사 완료"
fi

echo ""
echo "준비 완료! 오늘도 좋은 하루 되세요 :)"
