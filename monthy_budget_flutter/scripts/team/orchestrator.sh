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
#
# CRITICAL: "no results" and "could not ask" must never look the same.
#
# These used to end in `2>/dev/null || echo ""`, so a failed API call produced an
# empty list — indistinguishable from a genuinely empty label. During a GitHub
# outage that made the orchestrator believe the backlog was empty while 25 issues
# sat in qa:triage: it dispatched nothing, declared "loop 1 concluído", and
# promoted dev to main. A false victory built entirely on failed reads.
#
# So issues_with now RETURNS NON-ZERO when the query fails, and every caller has
# to decide what to do about not knowing.
# ONE query per cycle, then count locally.
#
# Per-label queries were both unreliable and expensive. `gh issue list --label X`
# returns a non-zero exit inconsistently — sometimes for an empty label, sometimes
# not, varying between consecutive identical calls under load — so "empty" and
# "failed" simply cannot be told apart from the exit code. And doing it per label
# meant 12+ API calls every 45-second cycle, which is a large part of why GitHub
# started rate-limiting this repo in the first place.
#
# Fetching every open issue once and filtering with jq fixes both: the failure mode
# becomes unambiguous (either a JSON array arrived or it did not), and the API load
# drops by an order of magnitude.
ISSUE_CACHE=""

refresh_issue_cache() {
  local json
  json=$(gh issue list --repo "$REPO" --state open --limit 300 \
         --json number,labels 2>/dev/null) || return 1
  # Explicit shape check: a truncated or error response must not pass as data.
  printf '%s' "$json" | jq -e 'type == "array"' >/dev/null 2>&1 || return 1
  ISSUE_CACHE="$json"
  return 0
}

# Issue numbers carrying a label, WORST FIRST, then oldest first. Reads the cache —
# no API call.
#
# Severity used to play no part in this at all: the order was `sort`, i.e. ascending
# issue number, i.e. filing order. The consequence was measured and bad. #1233 — a
# BLOCKER, "saving an expense records it twice", the user's money counted double —
# was filed at 16:06 and sat in qa:triage for seventeen hours without a single
# comment, queued behind eight sev:major issues, while the pipeline spent its last 75
# minutes on three implementation cycles of #1221: a sev:minor design nit about a
# header eyebrow. The pipeline was busy and working on the wrong things, which is the
# failure mode hardest to see from outside, because every log line looks healthy.
#
# Ordering by severity costs nothing and is the difference between a QA pipeline and
# a queue. Ties still break on issue number, so within a severity the oldest goes
# first and nothing starves. Issues with no sev: label sort LAST rather than first —
# an unlabelled finding is not evidence of importance, and the critic labels the ones
# it is sure about.
issues_with() {
  printf '%s' "$ISSUE_CACHE" \
    | jq -r --arg l "$1" '
        def sevrank(ns):
          if   (ns | index("sev:blocker")) then 0
          elif (ns | index("sev:major"))   then 1
          elif (ns | index("sev:minor"))   then 2
          else 3 end;
        [ .[]
          | select([.labels[].name] | index($l))
          | {n: .number, r: sevrank([.labels[].name])} ]
        | sort_by(.r, .n) | .[].n' \
      2>/dev/null
}

first_with() { issues_with "$1" | head -1; }

# ── Attempt budget per issue ───────────────────────────────────────────────
#
# Rework outranks new work in the dispatch order, which is right — finishing what
# is started beats starting more. But with no limit it means a single hard issue
# monopolises the pipeline indefinitely.
#
# Measured: #1202 (FAB overlap) went verify -> fail-impl -> implement -> review ->
# blocked-impl -> implement for over two hours, on its third implementation cycle,
# while 21 issues sat untouched in triage. From outside the pipeline looked busy and
# was delivering nothing.
#
# After this many round trips an issue is not "nearly there", it is stuck on
# something the agents cannot see — so park it for a human with the history intact
# and let the queue move.
MAX_ATTEMPTS="${TEAM_MAX_ATTEMPTS:-3}"
ATTEMPTS_DIR="$STATE_DIR/attempts"
mkdir -p "$ATTEMPTS_DIR" 2>/dev/null || true

bump_attempts() {
  local issue="$1" n
  n=$(( $(cat "$ATTEMPTS_DIR/$issue" 2>/dev/null || echo 0) + 1 ))
  echo "$n" > "$ATTEMPTS_DIR/$issue"
  printf '%s' "$n"
}

# ESCALATE THE STRATEGY, NEVER TO A HUMAN.
#
# Repeating the same approach after it has failed twice is the definition of a stuck
# loop — but parking the issue is not the answer either, because nobody is coming.
# So each exhaustion changes the APPROACH instead:
#
#   attempts 1-2   implement normally
#   attempt  3     hand it back to the curator WITH the full failure history, so the
#                  briefing is rewritten from what actually went wrong rather than
#                  from the original guess
#   attempt  4+    force a split: the issue is too big or too tangled to land whole,
#                  so break it into pieces each of which can
#
# Returns 0 to proceed with the normal action, 1 when it has been redirected.
escalate_if_stuck() {
  local issue="$1" n
  n=$(cat "$ATTEMPTS_DIR/$issue" 2>/dev/null || echo 0)
  [ "$n" -lt "$MAX_ATTEMPTS" ] && return 0

  if [ "$n" -lt $(( MAX_ATTEMPTS * 2 )) ]; then
    log "#$issue: $n tentativas — a devolver ao curator com o histórico de falhas"
    comment_issue "$issue" "## Orquestrador: mudar de abordagem após $n tentativas

Este issue já passou $n vezes pelo ciclo sem chegar a \`pass\`. Repetir a mesma
abordagem não vai resolver.

**Curator:** reescreve a análise a partir do que **falhou de facto** — os
comentários acima do reviewer e do verificador dizem exactamente onde é que cada
tentativa bateu. O plano original não estava a funcionar; procura outra via, ou
parte o issue se o problema for de tamanho."
    set_state "$issue" "$L_BLOCKED_SPEC"
    return 1
  fi

  log "#$issue: $n tentativas — a forçar split"
  comment_issue "$issue" "## Orquestrador: partir após $n tentativas

Duas rondas de reanálise não resolveram isto. O problema é de **tamanho ou de
emaranhado**, não de esforço.

**Curator:** usa \`split\`. Parte em pedaços em que cada um seja inequívoco e
resolúvel isoladamente — um ecrã, um viewport, um cálculo de cada vez. Se um pedaço
continuar a parecer difícil, parte-o outra vez. O histórico de falhas acima diz-te
onde estão as fronteiras naturais."
  echo 0 > "$ATTEMPTS_DIR/$issue"   # the pieces start fresh
  set_state "$issue" "$L_BLOCKED_SPEC"
  return 1
}

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
  # Kill only OUR agent tree, via the pgid run-agent.sh recorded, and only when
  # the lock is free (so no live agent is killed mid-run).
  local lock="/tmp/monthy-budget-agent.main.lock"
  if flock -w 0 -n "$lock" true 2>/dev/null; then

    # Stale verdicts, but ONLY the write-path roles this orchestrator owns, and
    # only now that we know none of its agents is live.
    #
    # This used to be an unconditional `rm -f "$VERDICT_DIR"/*.json` at the top of
    # every cycle, and it silently destroyed the critic's work. The critic runs
    # CONCURRENTLY on its own lock slots and writes into the same directory, so a
    # dimension that finished mid-cycle had its verdict deleted before it could be
    # filed. Measured: the `data` dimension produced 4 findings and every one was
    # lost, which from the outside looked like "the critic found nothing".
    #
    # critic-*.json is therefore never touched here — the critic owns its own
    # verdicts and deletes each one as soon as it has filed it.
    # The curator now runs on its OWN slot, so the main lock being free says nothing
    # about whether a curator is alive. Deleting its verdict here would repeat, exactly,
    # the bug that destroyed the critic's work: wiping the output of a live agent that
    # happens to run in another slot. So the curator is skipped whenever its own lock
    # is held.
    local roles="implement review verify"
    if flock -w 0 -n "/tmp/monthy-budget-agent.curator.lock" true 2>/dev/null; then
      roles="curator $roles"
    fi
    for role in $roles; do
      rm -f "$VERDICT_DIR/$role"-*.json 2>/dev/null || true
    done

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
  local issue pr
  for issue in $(issues_with "$L_WIP"); do
    # "No agent alive" does NOT mean "no work done". The implementer opens the PR and
    # only then transitions the issue, so a crash in that window leaves a real,
    # complete PR behind on an issue still marked qa:wip. Demoting that to qa:ready
    # dispatches a second implementer onto work already in review, on a branch that
    # already exists. So ask GitHub what exists before deciding, rather than
    # inferring what happened from the agent's absence.
    pr=$(gh pr list --repo "$REPO" --head "qa/issue-$issue" --base "$BASE_BRANCH" \
      --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")
    if [ -n "$pr" ]; then
      log "resgate: #$issue estava em $L_WIP mas o PR #$pr está aberto -> $L_REVIEW"
      comment_issue "$issue" "## Orquestrador: corrida interrompida depois do PR

O implementador morreu **depois** de abrir o PR #$pr, deixando o issue em
\`$L_WIP\`. O trabalho existe e o PR está aberto, por isso segue para
\`$L_REVIEW\` em vez de ser reimplementado."
      set_state "$issue" "$L_REVIEW"
      continue
    fi
    log "resgate: #$issue estava em $L_WIP sem agente vivo e sem PR -> $L_READY"
    comment_issue "$issue" "## Orquestrador: corrida interrompida

O issue estava em \`$L_WIP\`, nenhum agente estava vivo (timeout ou crash) e não
existe PR aberto para \`qa/issue-$issue\`.
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
# Launched DETACHED, deliberately.
#
# Two reasons it cannot be a normal inline step. First, a full sweep takes 30-70
# minutes; run inline it would freeze the single-threaded loop and no issue would
# be curated, implemented, reviewed or verified for that whole time. Second — and
# this is the bug this replaces — gating it behind "nothing else to do this cycle"
# means it never runs at all while a backlog exists, which is precisely the
# starvation it was meant to cure: one dimension's findings keep the queue busy
# forever and the other eight dimensions never execute.
#
# Safe to overlap with the write path: the critic only READS the app, takes its own
# lock slots per dimension, and files each verdict itself. (It was NOT safe until
# cleanup_stale stopped deleting critic-*.json out from under it.)
# ── When to ship dev -> main ────────────────────────────────────────────────
#
# Promotion itself costs no quota — it is git and gh, no agent. But each promotion
# to `main` fires release-tag.yml, which tags, releases and builds APK+AAB. Doing
# that per issue would mean two dozen releases, a mountain of CI (part of what got
# this repo rate-limited), and `main` shifting under the critic, which tests it.
#
# So promotion is BATCHED, and fires on whichever of these comes first:
#
#   end of the usage window  the natural moment: nothing is running, no quota is
#                            needed, and the fixes earned this window should not
#                            sit unshipped through an hour of cooldown
#   batch threshold reached  so a long productive window still ships periodically
#   backlog empty            the original condition, still valid
#
# Always gated on nothing being mid-flight — no open PR into dev, nothing awaiting
# verification or implementation. That is what "dev holds only finished work"
# actually means.
PROMOTE_BATCH="${TEAM_PROMOTE_BATCH:-6}"

maybe_promote() {
  local reason="$1" force="${2:-0}"
  [ "$RUN_PROMOTE" = "1" ] || return 0

  # ONLY qa:verify blocks a promotion.
  #
  # The first version also counted qa:review and qa:wip, and that was both wrong and
  # silent. Wrong: an issue in review has its code in a PR, NOT in dev — it cannot
  # affect what dev contains. In wip it is not even pushed. Only qa:verify means code
  # already merged into dev and not yet proven on the running app, which is the one
  # thing that must not be promoted.
  #
  # Silent: it returned without logging unless forced, so a pipeline that always had
  # something in review simply never promoted and never said why. dev reached 8
  # commits past the threshold with no trace in the log.
  local unverified
  unverified=$(issues_with "$L_VERIFY" | grep -c . || true)
  if [ "$unverified" -ne 0 ]; then
    log "promoção adiada: $unverified fix(es) integrados em $BASE_BRANCH ainda por verificar"
    return 0
  fi

  git -C "$TEAM_ROOT" fetch origin "$PROD_BRANCH" "$BASE_BRANCH" >/dev/null 2>&1 || true
  local ahead
  ahead=$(git -C "$TEAM_ROOT" rev-list --count \
          "origin/$PROD_BRANCH..origin/$BASE_BRANCH" 2>/dev/null || echo 0)
  [ "${ahead:-0}" -gt 0 ] || return 0

  if [ "$force" != "1" ] && [ "$ahead" -lt "$PROMOTE_BATCH" ]; then
    log "$ahead fix(es) verificados em $BASE_BRANCH — a acumular até $PROMOTE_BATCH ou ao fim da janela"
    return 0
  fi

  # An open promotion PR whose head already matches dev has nothing to add: re-running
  # promote.sh every 45s would just re-fetch, re-edit the body and re-arm a merge that
  # is already armed, while it waits for CI.
  local open_pr open_sha dev_sha
  open_pr=$(gh pr list --repo "$REPO" --head "$BASE_BRANCH" --base "$PROD_BRANCH" \
            --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")
  if [ -n "$open_pr" ]; then
    open_sha=$(gh pr view "$open_pr" --repo "$REPO" --json headRefOid --jq .headRefOid 2>/dev/null || echo "")
    dev_sha=$(git -C "$TEAM_ROOT" rev-parse "origin/$BASE_BRANCH" 2>/dev/null || echo "")
    if [ -n "$open_sha" ] && [ "$open_sha" = "$dev_sha" ]; then
      log "PR de promoção #$open_pr já cobre $BASE_BRANCH ($ahead commit(s)) — à espera dos gates"
      return 0
    fi
  fi

  # main's sha BEFORE, so we can tell "the promotion actually landed" from "a PR was
  # opened". Only the former means there is new production code to re-test.
  local main_before
  main_before=$(git -C "$TEAM_ROOT" rev-parse "origin/$PROD_BRANCH" 2>/dev/null || echo "")

  log "PROMOÇÃO ($reason) -> $ahead commit(s) verificados em $BASE_BRANCH"
  bash "$SCRIPT_DIR/promote.sh" || log "promoção falhou (segue-se em frente)"

  # A promotion changes `main`, which is exactly what the critic tests. New
  # production code means two things nobody has looked at: REGRESSIONS introduced
  # by the fixes, and whatever the previous sweep missed. So clear the coverage
  # record — the natural trigger for re-testing is "main changed", not "the queue
  # happens to be empty".
  #
  # The backlog threshold below is what stops that flooding the tracker: with a
  # deep queue of known-unfixed defects, a re-sweep mostly re-finds them, and
  # de-duplication throws the work away after the testers already spent the time.
  # Reset the sweep record only if main ACTUALLY moved. Opening or updating a
  # promotion PR changes nothing in production, and resetting on that would have the
  # critic re-sweeping a main it has already covered, every cycle the PR sits waiting
  # for CI.
  git -C "$TEAM_ROOT" fetch origin "$PROD_BRANCH" >/dev/null 2>&1 || true
  local main_after
  main_after=$(git -C "$TEAM_ROOT" rev-parse "origin/$PROD_BRANCH" 2>/dev/null || echo "")
  if [ -n "$main_after" ] && [ "$main_after" != "$main_before" ]; then
    # ...but ONLY when the queue was drained, i.e. this is a loop closing. A CADENCE
    # promotion mid-drain also moves main, and resetting there is what stalled
    # discovery all day.
    #
    # Measured over ~13 hours: 11 promotions moved main, coverage was reset 3 times,
    # and the critic swept ONCE while being deferred 35 times on "backlog > 8". Every
    # cadence promotion re-opened all nine dimensions, so the moment the queue fell to
    # the threshold a full sweep would refill it — and the loop counter needs the queue
    # at ZERO. Reset-on-any-move plus a backlog gate do not converge: they oscillate,
    # and the goal of two completed loops becomes unreachable by construction.
    #
    # Tying the reset to a drained queue gives the rhythm the pipeline was designed
    # for: sweep every dimension, drain what it found to zero, close the loop, ship
    # the batch, then re-open discovery against the main that batch produced. New
    # production code still gets re-tested — just once per loop instead of once per
    # promotion.
    if [ "$reason" = "backlog vazio" ]; then
      rm -f "$COVERED_DIMS_FILE"
      log "$PROD_BRANCH avançou para ${main_after:0:8} — cobertura reposta (loop fechado)"
    else
      log "$PROD_BRANCH avançou para ${main_after:0:8} — cobertura mantida (promoção de cadência, fila ainda por drenar)"
    fi
  fi
}

CRITIC_BG_PID=""
maybe_launch_critic_sweep() {
  # Still running from a previous cycle? Leave it alone.
  if [ -n "$CRITIC_BG_PID" ] && kill -0 "$CRITIC_BG_PID" 2>/dev/null; then
    return 0
  fi
  local pending; pending=$(uncovered_dims)
  [ -n "$pending" ] || return 1

  # Do not pile discovery onto a queue nobody can drain. Above this many open
  # actionable issues, a sweep mostly re-finds defects that are already filed and
  # waiting: de-duplication then discards the result, so the testers' time and
  # quota bought nothing. Below it, new findings can actually be acted on.
  local backlog
  backlog=$(count_actionable)
  if [ "$backlog" -gt "${TEAM_RESWEEP_MAX_BACKLOG:-8}" ]; then
    log "critic adiado: $backlog issues por tratar (limite ${TEAM_RESWEEP_MAX_BACKLOG:-8}) — corrigir primeiro"
    return 1
  fi

  log "CRITIC (em paralelo) -> dimensões a (re)varrer: $pending"
  nohup bash "$SCRIPT_DIR/critic.sh" \
    --branch "$PROD_BRANCH" \
    --dimensions "$(printf '%s' "$pending" | tr ' ' ',')" \
    >> "$LOG_DIR/critic-bg.log" 2>&1 &
  CRITIC_BG_PID=$!
  # Marked covered at launch, not at completion: a dimension that fails leaves its
  # reason in the log, and re-launching it every 45s would fork sweeps forever.
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

  # ── End of a usage window: ship, then KEEP WORKING on the fallback ────────
  #
  # I previously had this sleep until the quota returned, on the belief that the
  # fallback could not do the heavyweight roles. That belief was wrong, and reading
  # the actual logs disproved it: on the fallback, implement-1241 applied a two-part
  # fix, wrote new tests and ran the full suite (2408 passing), and curator-1242
  # produced a better briefing than some Claude runs — it even corrected the tester's
  # own account of the defect.
  #
  # The two failures I generalised from were not capability failures at all. One was
  # a 400 "this model does not support image input", because the prompts tell agents
  # to Read evidence screenshots — now handled by warning the agent when its engine
  # has no vision. So sleeping through the cooldown was throwing away an hour of
  # perfectly good throughput on a mistaken diagnosis.
  #
  # What still holds: promote at the window's end. Nothing is mid-flight, promotion
  # needs no quota, and the window's fixes should not wait an hour to reach main.
  COOLDOWN_FILE="$STATE_DIR/claude-usage-cooldown"
  if [ -f "$COOLDOWN_FILE" ]; then
    UNTIL=$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    if [ "$NOW" -lt "$UNTIL" ] && [ ! -f "$STATE_DIR/promoted-for-$UNTIL" ]; then
      log "fim da janela de quota (volta às $(date -d "@$UNTIL" +%H:%M)) — a promover e a continuar no fallback"
      if refresh_issue_cache; then
        maybe_promote "fim da janela de quota" 1
        touch "$STATE_DIR/promoted-for-$UNTIL"
      else
        log "não consegui ler os issues para promover — tento no próximo ciclo"
      fi
    fi
  fi

  # One read of the world per cycle. Everything below reasons from this snapshot.
  # If it fails we know nothing about the queue, so the cycle does nothing rather
  # than acting on a guess — which is how a false "loop concluído" and an unearned
  # promotion happened before.
  if ! refresh_issue_cache; then
    log "não consegui ler os issues (API falhou) — ciclo sem acções"
    if [ "$ONCE" = "1" ]; then exit 0; fi
    log "a aguardar ${CYCLE_SLEEP}s..."
    sleep "$CYCLE_SLEEP"
    continue
  fi

  rescue_stuck_wip

  # Discovery runs alongside fixing, never behind it.
  [ "$RUN_CRITIC" = "1" ] && maybe_launch_critic_sweep

  maybe_promote "cadência"

  DID=0

  # 0. Curate raw critic findings — DETACHED, and FIRST, before anything blocking.
  #
  # This used to block the cycle for the curator's full 17 minutes, which with a
  # global mutex meant 66 minutes of strictly serial agent time per issue. The
  # curator is the one role that costs nothing to run alongside the others: GitHub
  # comments and labels only, no git, no build, a 12MB worktree and ~200MB of RAM.
  #
  # POSITION IS THE WHOLE POINT, and getting it wrong made the change worthless.
  # Detached-but-last is not concurrent: this first sat at step 6, after the review /
  # verify / implement calls, each of which blocks the cycle for 9 to 25 minutes. The
  # launch was simply never reached until the heavy role had finished, so the curator
  # still ran strictly after it — the same serial order, now with extra machinery.
  # Observed live: at 13:33:49 the verifier was dispatched and no curator started.
  #
  # It runs FIRST instead, and sets no DID: launching the curator is not the cycle
  # having done its work, so the same pass goes on to dispatch a heavy role. That is
  # where the throughput comes from.
  if [ -z "$(first_with "$L_TRIAGE")" ]; then
    :
  elif ! flock -w 0 -n "/tmp/monthy-budget-agent.curator.lock" true 2>/dev/null; then
    log "curator já a correr no seu slot — a triagem espera a vez"
  else
    I=$(first_with "$L_TRIAGE")
    log "CURATOR (paralelo) -> #$I"
    nohup bash "$SCRIPT_DIR/curator.sh" "$I" \
      >> "$LOG_DIR/curator-bg.log" 2>&1 &
  fi


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
    if [ -n "$I" ]; then
      if escalate_if_stuck "$I"; then
        log "#$I: tentativa $(bump_attempts "$I") de $MAX_ATTEMPTS"
        run_implement "$I"
      fi
      DID=1
    fi
  fi

  # 4. Rework: briefing problems back to the curator.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_BLOCKED_SPEC")
    if [ -n "$I" ]; then
      # No escalation check here: this IS the escalation target. Counting it would
      # bounce the issue straight back out of the re-analysis it was sent for.
      run_curator "$I"
      DID=1
    fi
  fi

  # 5. Implement curated issues.
  if [ "$DID" = "0" ]; then
    I=$(first_with "$L_READY")
    if [ -n "$I" ]; then run_implement "$I"; DID=1; fi
  fi

  # 6. Backlog empty: that closes a loop. Run the critic to find the next batch.
  if [ "$DID" = "0" ]; then
    # Trustworthy by construction: the cycle already aborted if the snapshot this
    # counts could not be read.
    ACTIONABLE=$(count_actionable)

    # A background sweep still running counts as work in progress: closing the
    # loop now would call the backlog empty while findings are still arriving.
    if [ -n "$CRITIC_BG_PID" ] && kill -0 "$CRITIC_BG_PID" 2>/dev/null; then
      log "nada accionável, mas o critic ainda está a correr em paralelo"

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
      # Forced past the batch threshold: the queue is drained, so there is nothing
      # left to accumulate.
      maybe_promote "backlog vazio" 1

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
