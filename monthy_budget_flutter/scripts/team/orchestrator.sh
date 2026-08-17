#!/bin/bash
# orchestrator.sh — drives the QA pipeline. Runs locally.
#
# THE PIPELINE
#
#   critic (tests `main`)  ──filed──►  qa:triage
#                                          │ curator: root cause + plan + AC + test steps
#                                          ▼
#                                      qa:ready
#                                          │ implementer: fix on qa/issue-N, PR ──► dev
#                                          ▼
#                                      qa:review
#                                          │ reviewer: reads the diff, runs tests
#                          ┌───────────────┼───────────────┐
#                 blocked-impl        approved        blocked-spec
#                    (code)          + merged          (briefing)
#                          │               ▼               │
#                          │           qa:verify           │
#                          │               │ verifier: re-tests on the RUNNING dev build
#                          │   ┌───────────┼───────────┐   │
#                          └───┤ fail-impl │  pass     │   │
#                              └───────────┤    ▼      ├───┘
#                                          │  qa:done  │ fail-spec
#                                          │  (closed) │
#
# Exactly ONE qa:* label is an issue's state. Comments are the audit trail.
#
# One write-path agent at a time (they share a lock): two agents pushing to the
# same repo at once is how you get lost work. The critic's dimension testers are
# the exception — they only read the app, so they run in parallel.
#
# Usage:
#   orchestrator.sh [--once] [--loops N] [--issue N] [--pr N]
#                   [--no-critic] [--dimensions a,b,c]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="orchestrator"

ONCE=0
MAX_LOOPS=0            # 0 = forever
TARGET_ISSUE=""
TARGET_PR=""
RUN_CRITIC=1
RUN_PROMOTE=1
DIMENSIONS=""
CYCLE_SLEEP="${TEAM_CYCLE_SLEEP:-45}"

while [ $# -gt 0 ]; do
  case "$1" in
    --once) ONCE=1; shift ;;
    --loops) MAX_LOOPS="$2"; shift 2 ;;
    --loops=*) MAX_LOOPS="${1#--loops=}"; shift ;;
    --issue) TARGET_ISSUE="$2"; shift 2 ;;
    --issue=*) TARGET_ISSUE="${1#--issue=}"; shift ;;
    --pr) TARGET_PR="$2"; shift 2 ;;
    --pr=*) TARGET_PR="${1#--pr=}"; shift ;;
    --no-critic) RUN_CRITIC=0; shift ;;
    --no-promote) RUN_PROMOTE=0; shift ;;
    --dimensions) DIMENSIONS="$2"; shift 2 ;;
    --dimensions=*) DIMENSIONS="${1#--dimensions=}"; shift ;;
    *) shift ;;
  esac
done

REVIEWED_STATE="$STATE_DIR/reviewed-shas"
LOOP_STATE="$STATE_DIR/loops-completed"
touch "$REVIEWED_STATE" 2>/dev/null || true

# ── Issue queries ──────────────────────────────────────────────────────────
issues_with() {
  gh issue list --repo "$REPO" --label "$1" --state open --limit 100 \
    --json number --jq '.[].number' 2>/dev/null || echo ""
}

first_with() { issues_with "$1" | head -1; }

count_actionable() {
  local n=0 s
  for s in "$L_TRIAGE" "$L_READY" "$L_REVIEW" "$L_VERIFY" "$L_BLOCKED_IMPL" "$L_BLOCKED_SPEC" "$L_WIP"; do
    n=$(( n + $(issues_with "$s" | grep -c . || true) ))
  done
  echo "$n"
}

# ── PR selection ───────────────────────────────────────────────────────────
# Never just take the first open PR. Doing that produced an infinite loop in the
# sibling project: a PR the reviewer rightly blocked stays OPEN, so the next
# cycle picked it up again — 184 reviews of the same commit in one night, ~22% of
# the weekly quota burned, and the implementer never ran because there was always
# a PR ahead of it.
#
# A PR is only reviewed again when its HEAD MOVES. Re-reviewing the same commit
# cannot produce a different answer.
pick_pr() {
  local list line num sha
  list=$(gh pr list --repo "$REPO" --base "$BASE_BRANCH" --state open \
           --json number,headRefOid,headRefName \
           --jq '.[] | select(.headRefName | startswith("qa/")) | "\(.number) \(.headRefOid)"' \
           2>/dev/null || echo "")
  [ -n "$list" ] || return 0
  # here-string, not a pipe: with `set -o pipefail` a `| head -1` closes the pipe,
  # the writer takes SIGPIPE and the ORCHESTRATOR DIES — systemd restarts it and
  # the log fills with "cycle 1" forever.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    num=${line%% *}; sha=${line##* }
    if ! grep -qxF "$num $sha" "$REVIEWED_STATE" 2>/dev/null; then
      echo "$num"; return 0
    fi
  done <<< "$list"
  return 0
}

mark_reviewed() {
  local num="$1" sha
  sha=$(gh pr view "$num" --repo "$REPO" --json headRefOid --jq '.headRefOid' 2>/dev/null || echo "")
  [ -n "$sha" ] || return 0
  echo "$num $sha" >> "$REVIEWED_STATE"
  tail -300 "$REVIEWED_STATE" > "$REVIEWED_STATE.tmp" && mv "$REVIEWED_STATE.tmp" "$REVIEWED_STATE"
}

# ── Stale cleanup ──────────────────────────────────────────────────────────
# Nothing survives from one cycle to the next. An inherited verdict makes an
# agent report the PREVIOUS run's work as its own.
cleanup_stale() {
  rm -f "$VERDICT_DIR"/*.json 2>/dev/null || true

  # Kill only OUR agent tree, via the pgid run-agent.sh recorded, and only when
  # the lock is free (so no live agent is killed mid-run).
  local lock="/tmp/monthy-budget-agent.main.lock"
  if flock -w 0 -n "$lock" true 2>/dev/null; then
    local pgidfile="$lock.pgid"
    if [ -f "$pgidfile" ]; then
      local pgid; pgid=$(cat "$pgidfile" 2>/dev/null || echo "")
      if [ -n "$pgid" ] && kill -0 -"$pgid" 2>/dev/null; then
        log "stale: a matar a árvore do agente (pgid $pgid)"
        kill -TERM -"$pgid" 2>/dev/null || true
        sleep 2
        kill -KILL -"$pgid" 2>/dev/null || true
      fi
      rm -f "$pgidfile"
    fi
    # Agent worktrees, but NOT the serve-* ones: those hold the running builds.
    for wt in "$WT_ROOT"/implement-* "$WT_ROOT"/review-* "$WT_ROOT"/curator-*; do
      [ -e "$wt" ] || continue
      log "stale: a remover worktree $(basename "$wt")"
      wt_remove "$wt"
    done
    git -C "$TEAM_ROOT" worktree prune 2>/dev/null || true
  fi
}

# An issue stuck in qa:wip with no agent alive means the implementer died. Left
# alone it blocks that issue forever, because nothing dispatches on qa:wip.
rescue_stuck_wip() {
  local lock="/tmp/monthy-budget-agent.main.lock"
  flock -w 0 -n "$lock" true 2>/dev/null || return 0   # an agent is running; leave it
  local issue
  for issue in $(issues_with "$L_WIP"); do
    log "resgate: #$issue estava em $L_WIP sem agente vivo -> $L_READY"
    comment_issue "$issue" "## Orquestrador: corrida interrompida

O issue estava em \`$L_WIP\` mas nenhum agente estava vivo (timeout ou crash).
Devolvido a \`$L_READY\` para nova tentativa."
    set_state "$issue" "$L_READY"
  done
}

# ── Role dispatch ──────────────────────────────────────────────────────────
run_curator()   { log "CURATOR -> #$1";     bash "$SCRIPT_DIR/curator.sh" "$1"   || log "curator falhou #$1"; }
run_implement() { log "IMPLEMENTADOR -> #$1"; bash "$SCRIPT_DIR/implement.sh" "$1" || log "implement falhou #$1"; }
run_verify()    { log "QA VERIFIER -> #$1"; bash "$SCRIPT_DIR/verify.sh" "$1"    || log "verify falhou #$1"; }
run_review()    { log "REVIEWER -> PR #$1"; bash "$SCRIPT_DIR/review.sh" "$1"    || log "review falhou PR #$1"; mark_reviewed "$1"; }

run_critic() {
  log "CRITIC -> a testar '$PROD_BRANCH'"
  local args=(--branch "$PROD_BRANCH")
  [ -n "$DIMENSIONS" ] && args+=(--dimensions "$DIMENSIONS")
  bash "$SCRIPT_DIR/critic.sh" "${args[@]}" || log "critic falhou"
}

# Which dimensions have already been swept in this session.
COVERED_DIMS_FILE="$STATE_DIR/dims-covered"
ALL_CRITIC_DIMS="functional layout design ux a11y i18n perf console data"

# Dimensions never yet run against the current production code.
uncovered_dims() {
  local out=""
  local candidates="${DIMENSIONS:+$(printf '%s' "$DIMENSIONS" | tr ',' ' ')}"
  [ -n "$candidates" ] || candidates="$ALL_CRITIC_DIMS"
  for d in $candidates; do
    grep -qxF "$d" "$COVERED_DIMS_FILE" 2>/dev/null || out="$out $d"
  done
  printf '%s' "${out# }"
}

mark_dims_covered() {
  for d in $1; do echo "$d" >> "$COVERED_DIMS_FILE"; done
}

# DISCOVERY MUST NOT WAIT FOR FIXING.
#
# The critic originally ran only when the backlog hit zero, which sounded prudent
# — don't file faster than you fix — but starved discovery badly: on the first
# real run a single dimension's findings kept the queue busy for over an hour
# while SEVEN dimensions had never executed once. The tracker looked healthy with
# four issues while most of the app had never been examined at all.
#
# So: any dimension that has never run against production code gets swept as soon
# as no write-path work is pending in this cycle, regardless of backlog depth.
# Once every dimension has been covered once, we fall back to the
# drain-then-resweep rhythm, which is the right steady state.
run_uncovered_critic() {
  local pending; pending=$(uncovered_dims)
  [ -n "$pending" ] || return 1
  log "CRITIC (cobertura inicial) -> dimensões nunca corridas: $pending"
  local args=(--branch "$PROD_BRANCH" --dimensions "$(printf '%s' "$pending" | tr ' ' ',')")
  bash "$SCRIPT_DIR/critic.sh" "${args[@]}" || log "critic falhou"
  mark_dims_covered "$pending"
  return 0
}

# ── Explicit targets ───────────────────────────────────────────────────────
if [ -n "$TARGET_PR" ]; then run_review "$TARGET_PR"; exit 0; fi

if [ -n "$TARGET_ISSUE" ]; then
  STATE=$(get_state "$TARGET_ISSUE")
  log "target #$TARGET_ISSUE estado=${STATE:-nenhum}"
  case "$STATE" in
    "$L_TRIAGE"|"$L_BLOCKED_SPEC") run_curator "$TARGET_ISSUE" ;;
    "$L_READY"|"$L_BLOCKED_IMPL")  run_implement "$TARGET_ISSUE" ;;
    "$L_VERIFY")                   run_verify "$TARGET_ISSUE" ;;
    *) log "#$TARGET_ISSUE não está num estado accionável (${STATE:-sem estado})" ;;
  esac
  exit 0
fi

# ── Main loop ──────────────────────────────────────────────────────────────
CYCLE=0
LOOPS=$(cat "$LOOP_STATE" 2>/dev/null || echo 0)
# A "loop" = the critic found work AND the backlog was drained back to zero.
# Counted per session, so the tally reflects this run rather than all history.
CRITIC_RUNS=0
log "arranque. loops já concluídos (histórico): $LOOPS. base=$BASE_BRANCH prod=$PROD_BRANCH"

while true; do
  CYCLE=$((CYCLE + 1))
  log "──── ciclo $CYCLE (loops concluídos: $LOOPS) ────"

  cleanup_stale
  rescue_stuck_wip

  DID=0

  # Priority order matters. Reviewing first is what unblocks merges; verifying
  # next is what closes issues. Only then do we start new work — otherwise the
  # backlog grows faster than it drains and nothing ever reaches qa:done.

  # 1. Review open PRs whose head has moved since the last review.
  PR=$(pick_pr)
  if [ -n "$PR" ]; then run_review "$PR"; DID=1; fi

  # 2. Verify merged fixes on dev.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_VERIFY")
    if [ -n "$I" ]; then run_verify "$I"; DID=1; fi
  fi

  # 3. Rework: code problems back to the implementer.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_BLOCKED_IMPL")
    if [ -n "$I" ]; then run_implement "$I"; DID=1; fi
  fi

  # 4. Rework: briefing problems back to the curator.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_BLOCKED_SPEC")
    if [ -n "$I" ]; then run_curator "$I"; DID=1; fi
  fi

  # 5. Implement curated issues.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_READY")
    if [ -n "$I" ]; then run_implement "$I"; DID=1; fi
  fi

  # 6. Curate raw critic findings.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_TRIAGE")
    if [ -n "$I" ]; then run_curator "$I"; DID=1; fi
  fi

  # 7. Backlog empty: that closes a loop. Run the critic to find the next batch.
  if [ "$DID" = "0" ]; then
    ACTIONABLE=$(count_actionable)

    # Sweep any never-run dimension before waiting on the backlog: discovery of
    # whole untested areas is worth more than keeping the queue short.
    if [ "$RUN_CRITIC" = "1" ] && run_uncovered_critic; then
      CRITIC_RUNS=$((CRITIC_RUNS + 1))
      DID=1

    elif [ "$ACTIONABLE" -gt 0 ]; then
      log "nada accionável neste ciclo mas ainda há $ACTIONABLE issue(s) em curso"

    elif [ "$CRITIC_RUNS" -eq 0 ]; then
      # First cycle of the session and the backlog is already empty: nothing has
      # been found or fixed yet, so this is NOT a completed loop. Counting it
      # would make `--loops 2` deliver only ONE real find-fix-verify-ship cycle.
      log "backlog vazio no arranque — a lançar o critic para encontrar trabalho"
      if [ "$RUN_CRITIC" = "1" ]; then
        run_critic
        CRITIC_RUNS=$((CRITIC_RUNS + 1))
        DID=1
      else
        log "--no-critic: nada para fazer"
      fi

    else
      LOOPS=$((LOOPS + 1))
      echo "$LOOPS" > "$LOOP_STATE"
      log "backlog vazio — loop $LOOPS concluído"

      # Ship what QA verified. Without this the critic keeps re-testing a `main`
      # that never receives the fixes, and finds the same defects every loop.
      if [ "$RUN_PROMOTE" = "1" ]; then
        log "PROMOÇÃO -> $BASE_BRANCH para $PROD_BRANCH"
        bash "$SCRIPT_DIR/promote.sh" || log "promoção falhou (segue-se em frente)"
      fi

      if [ "$MAX_LOOPS" -gt 0 ] && [ "$LOOPS" -ge "$MAX_LOOPS" ]; then
        log "atingidos os $MAX_LOOPS loops pedidos. A terminar."
        exit 0
      fi

      if [ "$RUN_CRITIC" = "1" ]; then
        run_critic
        CRITIC_RUNS=$((CRITIC_RUNS + 1))
        DID=1
      else
        log "--no-critic: nada para fazer"
      fi
    fi
  fi

  if [ "$ONCE" = "1" ]; then
    log "──── fim (once) ────"
    exit 0
  fi

  log "a aguardar ${CYCLE_SLEEP}s..."
  sleep "$CYCLE_SLEEP"
done
