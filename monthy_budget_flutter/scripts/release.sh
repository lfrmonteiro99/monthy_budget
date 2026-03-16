#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ALLOW_DIRTY=0
DRY_RUN=0
FORCED_BUMP=""

usage() {
  cat <<EOF
Usage: bash scripts/release.sh [--allow-dirty] [--dry-run] [--bump patch|minor|major]

  --allow-dirty  Proceed even if working tree has changes
  --dry-run      Compute and print release data without writing/pushing
  --bump TYPE    Force release type: patch | minor | major

Flow:
  1. Compute next version from tags + commits
  2. Create release branch with version bump + changelog
  3. Push branch + create GitHub issue + create PR
  4. On PR merge, release-tag.yml creates git tag + GitHub Release
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --bump)
      if [[ $# -lt 2 ]]; then echo "Missing value for --bump"; usage; exit 1; fi
      FORCED_BUMP="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# ── Prerequisites ──────────────────────────────────────────────────
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"; exit 1
  fi
}
require_cmd git
require_cmd git-cliff
require_cmd gh

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository."; exit 1
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "gh CLI is not authenticated. Run 'gh auth login' first."; exit 1
fi

# ── Resolve default branch ────────────────────────────────────────
DEFAULT_BRANCH="$(
  git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null \
    | sed 's#^origin/##' || true
)"
if [[ -z "$DEFAULT_BRANCH" ]]; then
  DEFAULT_BRANCH="$(
    git remote show origin 2>/dev/null \
      | sed -n '/HEAD branch/s/.*: //p' | head -n 1 || true
  )"
fi
: "${DEFAULT_BRANCH:=main}"

# ── Guards ─────────────────────────────────────────────────────────
if [[ $ALLOW_DIRTY -ne 1 ]]; then
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Working tree is not clean. Commit/stash or pass --allow-dirty."
    exit 1
  fi
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]]; then
  echo "Release must be executed from '$DEFAULT_BRANCH' (current: '$CURRENT_BRANCH')."
  exit 1
fi

# ── Fetch tags + latest main ──────────────────────────────────────
git fetch --tags origin "$DEFAULT_BRANCH"

LAST_TAG="$(git tag --list 'v20*' --sort=-v:refname | head -n 1 || true)"
RANGE=""
if [[ -n "$LAST_TAG" ]]; then
  RANGE="${LAST_TAG}..HEAD"
fi

COMMITS="$(git log ${RANGE} --pretty=format:'%s%n%b' || true)"
if [[ -z "${COMMITS// }" ]]; then
  echo "No commits since last release ($LAST_TAG)."
  exit 1
fi

# ── Detect bump type ──────────────────────────────────────────────
BUMP="patch"
if echo "$COMMITS" | grep -Eiq 'BREAKING CHANGE|^[a-zA-Z]+!:'; then
  BUMP="major"
elif echo "$COMMITS" | grep -Eiq '(^|\n)feat(\(|:)|feature'; then
  BUMP="minor"
fi

if [[ -n "$FORCED_BUMP" ]]; then
  case "$FORCED_BUMP" in
    patch|minor|major) BUMP="$FORCED_BUMP" ;;
    *) echo "Invalid --bump value: '$FORCED_BUMP'. Use patch|minor|major."; exit 1 ;;
  esac
fi

# ── Compute version ───────────────────────────────────────────────
CURRENT_YEAR="$(date +%Y)"
CURRENT_MONTH=$((10#$(date +%m)))

if [[ -z "$LAST_TAG" ]]; then
  YEAR="$CURRENT_YEAR"; MONTH="$CURRENT_MONTH"; PATCH=0
else
  BASE="${LAST_TAG#v}"
  IFS='.' read -r PREV_YEAR PREV_MONTH PREV_PATCH <<< "$BASE"

  case "$BUMP" in
    major)
      if (( CURRENT_YEAR <= PREV_YEAR )); then YEAR=$((PREV_YEAR + 1)); else YEAR="$CURRENT_YEAR"; fi
      MONTH=1; PATCH=0 ;;
    minor)
      if (( CURRENT_YEAR > PREV_YEAR || (CURRENT_YEAR == PREV_YEAR && CURRENT_MONTH > PREV_MONTH) )); then
        YEAR="$CURRENT_YEAR"; MONTH="$CURRENT_MONTH"
      else
        YEAR="$PREV_YEAR"; MONTH=$((PREV_MONTH + 1))
        if (( MONTH > 12 )); then YEAR=$((YEAR + 1)); MONTH=1; fi
      fi
      PATCH=0 ;;
    patch)
      if (( CURRENT_YEAR > PREV_YEAR || (CURRENT_YEAR == PREV_YEAR && CURRENT_MONTH > PREV_MONTH) )); then
        YEAR="$CURRENT_YEAR"; MONTH="$CURRENT_MONTH"; PATCH=1
      else
        YEAR="$PREV_YEAR"; MONTH="$PREV_MONTH"; PATCH=$((PREV_PATCH + 1))
      fi ;;
  esac
fi

VERSION_NAME="${YEAR}.${MONTH}.${PATCH}"
YY=$((YEAR % 100))
VERSION_CODE=$((YY * 10000000 + MONTH * 100000 + PATCH))
TAG="v${VERSION_NAME}"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag already exists: $TAG"; exit 1
fi

echo "Release type: $BUMP"
echo "Version: $VERSION_NAME"
echo "Version code: $VERSION_CODE"
echo "Tag: $TAG"

if ! grep -Eq '^version:' pubspec.yaml; then
  echo "pubspec.yaml version field not found"; exit 1
fi

# ── Dry run stops here ────────────────────────────────────────────
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run: no files changed, no commit/push/PR."
  exit 0
fi

# ── Create release branch ─────────────────────────────────────────
RELEASE_BRANCH="release/${TAG}"
git checkout -b "$RELEASE_BRANCH"

# ── Update pubspec.yaml ───────────────────────────────────────────
awk -v v="${VERSION_NAME}+${VERSION_CODE}" '
  BEGIN { done=0 }
  /^version:/ { print "version: " v; done=1; next }
  { print }
  END { if (done==0) exit 2 }
' pubspec.yaml > pubspec.yaml.tmp
mv pubspec.yaml.tmp pubspec.yaml

# ── Generate changelog ────────────────────────────────────────────
if [[ -n "$LAST_TAG" ]]; then
  git-cliff "$LAST_TAG"..HEAD --tag "$TAG" -o CHANGELOG.md
else
  git-cliff --tag "$TAG" -o CHANGELOG.md
fi

# ── Commit + push branch ──────────────────────────────────────────
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): ${TAG}"
git push -u origin "$RELEASE_BRANCH"

# ── Create GitHub issue ───────────────────────────────────────────
echo "Creating release issue..."
ISSUE_URL="$(gh issue create \
  --title "Release ${TAG}" \
  --body "$(cat <<IBODY
Automated release ${TAG} (${BUMP}).

### Changes since ${LAST_TAG:-"initial"}
$(git log ${RANGE} --pretty='- %s' || echo '- Initial release')
IBODY
)")"

ISSUE_NUMBER="$(printf '%s\n' "$ISSUE_URL" | sed -E 's#.*/issues/([0-9]+).*#\1#')"
echo "Created issue #${ISSUE_NUMBER}"

# ── Build release notes for PR body ───────────────────────────────
RELEASE_NOTES="$(git log ${RANGE} --pretty='- %s' || echo '- Initial release')"

# ── Create PR ─────────────────────────────────────────────────────
echo "Creating release PR..."
PR_URL="$(gh pr create \
  --base "$DEFAULT_BRANCH" \
  --head "$RELEASE_BRANCH" \
  --title "chore(release): ${TAG}" \
  --label "release:${BUMP}" \
  --body "$(cat <<PBODY
## Linked Issue
Fixes #${ISSUE_NUMBER}

## Summary
Release ${TAG} — ${BUMP} bump.

## Release Notes
${RELEASE_NOTES}
PBODY
)")"

echo ""
echo "══════════════════════════════════════════════════"
echo "  Release ${TAG} prepared successfully!"
echo "  Issue:  ${ISSUE_URL}"
echo "  PR:     ${PR_URL}"
echo "══════════════════════════════════════════════════"
echo ""
echo "Next: PR merges → release-tag.yml creates tag + GitHub Release."

# ── Return to default branch ──────────────────────────────────────
git checkout "$DEFAULT_BRANCH"
