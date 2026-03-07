#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-}"
BODY="${2:-}"
LABELS="${3:-chore}"

if [[ -z "$TITLE" ]]; then
  echo "Usage: bash scripts/create_or_get_issue.sh \"<title>\" \"<body>\" [labels]"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required."
  exit 1
fi

EXISTING="$(gh issue list --search "$TITLE in:title state:open" --limit 1 --json number --jq '.[0].number // empty')"

if [[ -n "$EXISTING" ]]; then
  echo "$EXISTING"
  exit 0
fi

if [[ -z "$BODY" ]]; then
  BODY="Auto-created issue for task: $TITLE"
fi

ISSUE_NUMBER="$(gh issue create --title "$TITLE" --body "$BODY" --label "$LABELS" --json number --jq .number)"
echo "$ISSUE_NUMBER"
