#!/bin/bash
# lib.sh — shared configuration and helpers for the QA pipeline agents.
# Sourced by every role script. Not executable on its own.

# ── Repository / paths ─────────────────────────────────────────────────────
REPO="${TEAM_REPO:-lfrmonteiro99/monthy_budget}"

# Repo root (the git top level), and the Flutter package inside it.
TEAM_ROOT="${TEAM_ROOT:-$HOME/Documentos/monthy_budget}"
FLUTTER_SUBDIR="monthy_budget_flutter"

# Branch topology:
#   main — production. The CRITIC tests the app built from here.
#   dev  — QA staging. Fixes land here first and the VERIFIER re-tests them here.
#   qa/* — implementer working branches; their PRs target dev.
BASE_BRANCH="${TEAM_BASE_BRANCH:-dev}"
PROD_BRANCH="${TEAM_PROD_BRANCH:-main}"

# Verdicts live OUTSIDE the repository.
#
# Inside the working tree they caused three separate failures at once in the
# sibling project this harness is modelled on: they got committed, a run that
# died before writing inherited the PREVIOUS run's verdict and reported another
# issue's work as its own, and `git add -A` dragged them into the PR diff.
# Outside the repo none of the three is possible.
VERDICT_DIR="${TEAM_VERDICT_DIR:-$HOME/Documentos/monthy-budget-verdicts}"

# Worktrees are siblings of the repo, never inside it: a worktree nested in the
# repo shows up as untracked content and eventually gets committed by accident.
WT_ROOT="${TEAM_WT_ROOT:-$HOME/Documentos/monthy-budget-wt}"

LOG_DIR="${TEAM_LOG_DIR:-/tmp/monthy-budget-team}"
STATE_DIR="${TEAM_STATE_DIR:-$HOME/Documentos/monthy-budget-verdicts/state}"

# Ports for the served QA builds. One per branch so the critic (main) and the
# verifier (dev) can run against different code at the same time.
PORT_PROD="${TEAM_PORT_PROD:-7401}"
PORT_DEV="${TEAM_PORT_DEV:-7402}"

mkdir -p "$VERDICT_DIR" "$LOG_DIR" "$STATE_DIR" "$WT_ROOT" 2>/dev/null || true

# ── Labels: the pipeline state machine ─────────────────────────────────────
# Exactly one qa:* label is the authoritative state of an issue. Comments are
# the audit trail; the label is what the orchestrator dispatches on.
L_TRIAGE="qa:triage"              # critic filed it, awaiting curator
L_READY="qa:ready"                # curated: root cause + plan + AC + test steps
L_WIP="qa:wip"                    # implementer working
L_REVIEW="qa:review"              # PR open into dev, awaiting reviewer
L_VERIFY="qa:verify"              # merged to dev, awaiting QA re-test
L_DONE="qa:done"                  # verified on dev
L_BLOCKED_IMPL="qa:blocked-impl"  # back to implementer (code problem)
L_BLOCKED_SPEC="qa:blocked-spec"  # back to curator (spec problem)
L_HUMAN="qa:needs-human"          # pipeline gave up

ALL_QA_LABELS="$L_TRIAGE,$L_READY,$L_WIP,$L_REVIEW,$L_VERIFY,$L_DONE,$L_BLOCKED_IMPL,$L_BLOCKED_SPEC,$L_HUMAN"

log() { echo "[${ROLE:-team}] $(date +%H:%M:%S) $*"; }
warn() { echo "[${ROLE:-team}] $(date +%H:%M:%S) WARN $*" >&2; }

# ── Issue state transitions ────────────────────────────────────────────────
# Move an issue to exactly one qa:* state, clearing the others. `--add-label`
# and `--remove-label` in one call is what keeps this atomic enough: GitHub
# applies both, so an issue never briefly carries two states.
set_state() {
  local issue="$1" state="$2"
  local remove
  # Remove every qa:* label except the one being set.
  remove=$(printf '%s' "$ALL_QA_LABELS" | tr ',' '\n' | grep -vxF "$state" | paste -sd, -)
  gh issue edit "$issue" --repo "$REPO" \
    --add-label "$state" --remove-label "$remove" >/dev/null 2>&1 \
    || warn "não consegui pôr #$issue em $state"
}

# Read the single qa:* state label of an issue ("" when it has none).
get_state() {
  local issue="$1"
  gh issue view "$issue" --repo "$REPO" --json labels \
    --jq '[.labels[].name] | map(select(startswith("qa:"))) | .[0] // ""' 2>/dev/null || echo ""
}

comment_issue() {
  local issue="$1" body="$2"
  gh issue comment "$issue" --repo "$REPO" --body "$body" >/dev/null 2>&1 \
    || warn "não consegui comentar #$issue"
}

# ── Verdict helpers ────────────────────────────────────────────────────────
# NOTE ON `head -c`: never pipe a verdict field through `head -c N`. Under
# `set -euo pipefail`, when the value is longer than N, head closes the pipe,
# the writer takes SIGPIPE, and the SCRIPT DIES mid-run. Truncate with bash
# parameter expansion (`${v:0:N}`) instead — no pipe, no subshell, no signal.
#
# NOTE ON NAMING: keep the path variable and the value variable distinct.
# `VERDICT=$(jq ... "$VERDICT")` overwrites the path with the value, and the
# next jq call then tries to open a file named "blocked".
jqv() {
  local file="$1" filter="$2" fallback="${3:-}"
  local out
  out=$(jq -r "$filter" "$file" 2>/dev/null) || out=""
  [ "$out" = "null" ] && out=""
  printf '%s' "${out:-$fallback}"
}

# ── Git worktrees ──────────────────────────────────────────────────────────
# A Flutter worktree needs `flutter pub get` and generated l10n before anything
# can analyze, test or build in it.
wt_prepare_flutter() {
  local wt="$1"
  local pkg="$wt/$FLUTTER_SUBDIR"
  [ -d "$pkg" ] || return 0
  ( cd "$pkg" && flutter pub get >/dev/null 2>&1 && flutter gen-l10n >/dev/null 2>&1 ) \
    || warn "pub get / gen-l10n falhou em $pkg"
}

# Create a worktree on a NEW branch cut from $BASE_BRANCH. This is what the
# IMPLEMENTER wants.
#
# Do NOT use this to review a PR. If the branch doesn't exist locally, `-b`
# creates it pointing at the base, the worktree ends up holding the BASE's
# content, `git diff base...HEAD` returns EMPTY, and the reviewer reviews
# nothing at all — with no error in the log. Use wt_checkout for that.
wt_create() {
  local branch="$1" dirname="$2" base="${3:-$BASE_BRANCH}"
  local wt="$WT_ROOT/$dirname"
  git -C "$TEAM_ROOT" fetch origin "$base" >/dev/null 2>&1 || true
  # Also fetch the work branch itself: on REWORK it already exists on the remote
  # and carries the previous attempt.
  git -C "$TEAM_ROOT" fetch origin \
    "+refs/heads/$branch:refs/remotes/origin/$branch" >/dev/null 2>&1 || true

  if git -C "$TEAM_ROOT" rev-parse --verify --quiet "origin/$branch" >/dev/null 2>&1; then
    # REWORK. Start from the REMOTE tip, not from any local branch of the same
    # name: a leftover local ref is usually behind what was pushed, and since
    # implement.sh finishes with `push --force`, resuming from it would silently
    # discard the previous attempt — including the very code the reviewer asked
    # to have corrected. Detached, then re-pointed at the end by the push.
    git -C "$TEAM_ROOT" worktree add --detach "$wt" "origin/$branch" >/dev/null 2>&1 \
      || { warn "não criou worktree $wt em origin/$branch"; return 1; }
    git -C "$wt" checkout -B "$branch" >/dev/null 2>&1 || true
  else
    git -C "$TEAM_ROOT" worktree add "$wt" -b "$branch" "origin/$base" >/dev/null 2>&1 \
      || git -C "$TEAM_ROOT" worktree add "$wt" "$branch" >/dev/null 2>&1 \
      || { warn "não criou worktree $wt para $branch"; return 1; }
  fi
  echo "$wt"
}

# Check out an EXISTING remote branch, detached. This is what the REVIEWER and
# the app server want: the tree must hold the code under test, not a fresh
# branch off the base.
wt_checkout() {
  local ref_name="$1" dirname="$2"
  local wt="$WT_ROOT/$dirname"
  git -C "$TEAM_ROOT" fetch origin \
    "+refs/heads/$ref_name:refs/remotes/origin/$ref_name" >/dev/null 2>&1 || true
  local ref=""
  for cand in "origin/$ref_name" "$ref_name"; do
    if git -C "$TEAM_ROOT" rev-parse --verify --quiet "$cand" >/dev/null 2>&1; then
      ref="$cand"; break
    fi
  done
  if [ -z "$ref" ]; then
    warn "branch '$ref_name' não existe no remoto nem localmente"
    return 1
  fi
  git -C "$TEAM_ROOT" worktree add --detach "$wt" "$ref" >/dev/null 2>&1 \
    || { warn "não criou worktree $wt em $ref"; return 1; }
  echo "$wt"
}

wt_remove() {
  local wt="$1"
  [ -n "$wt" ] && [ -d "$wt" ] || return 0
  git -C "$TEAM_ROOT" worktree remove --force "$wt" >/dev/null 2>&1 || rm -rf "$wt"
  local branch
  branch=$(basename "$wt")
  git -C "$TEAM_ROOT" branch -D "$branch" >/dev/null 2>&1 || true
}
