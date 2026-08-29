#!/bin/bash
# lib.sh — shared configuration and helpers for the QA pipeline agents.
# Sourced by every role script. Not executable on its own.

# ── Repository / paths ─────────────────────────────────────────────────────
# Where the role scripts live. Resolved from this file so helpers here can invoke
# siblings (serve-app.sh, run-agent.sh) without every caller passing a path.
TEAM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# The pre-merge gate serves the PR's own branch, so it needs a port of its own:
# the critic may be driving 7401 and the verifier 7402 at the same moment, and a
# gate that reused either would test whichever build happened to be up — exactly
# the confusion it exists to prevent.
PORT_PREMERGE="${TEAM_PORT_PREMERGE:-7403}"

# Which critic dimensions have already run against the CURRENT production code.
# Shared: the orchestrator reads it to decide what to sweep, and critic.sh writes it
# as each dimension actually starts. Ownership matters here — see the comment at the
# write site.
COVERED_DIMS_FILE="${TEAM_STATE_DIR:-/tmp/monthy-budget-team/state}/dims-covered"

mkdir -p "$VERDICT_DIR" "$LOG_DIR" "$STATE_DIR" "$WT_ROOT" 2>/dev/null || true

# ── Labels: the pipeline state machine ─────────────────────────────────────
# Exactly one qa:* label is the authoritative state of an issue. Comments are
# the audit trail; the label is what the orchestrator dispatches on.
L_TRIAGE="qa:triage"              # critic filed it, awaiting curator
L_READY="qa:ready"                # curated: root cause + plan + AC + test steps
L_WIP="qa:wip"                    # implementer working
L_REVIEW="qa:review"              # PR open into dev, awaiting reviewer
L_PREMERGE="qa:premerge"          # approved by the reviewer, awaiting the browser gate
L_VERIFY="qa:verify"              # merged to dev, awaiting QA re-test
L_DONE="qa:done"                  # verified on dev
L_BLOCKED_IMPL="qa:blocked-impl"  # back to implementer (code problem)
L_BLOCKED_SPEC="qa:blocked-spec"  # back to curator (spec problem)
L_HUMAN="qa:needs-human"          # pipeline gave up

ALL_QA_LABELS="$L_TRIAGE,$L_READY,$L_WIP,$L_REVIEW,$L_PREMERGE,$L_VERIFY,$L_DONE,$L_BLOCKED_IMPL,$L_BLOCKED_SPEC,$L_HUMAN"

log() { echo "[${ROLE:-team}] $(date +%H:%M:%S) $*"; }
warn() { echo "[${ROLE:-team}] $(date +%H:%M:%S) WARN $*" >&2; }

# ── Issue state transitions ────────────────────────────────────────────────
# Move an issue to exactly one qa:* state, clearing the others. `--add-label`
# and `--remove-label` in one call is what keeps this atomic enough: GitHub
# applies both, so an issue never briefly carries two states.
# Move an issue to exactly one qa:* state, VERIFYING the change landed.
#
# It used to fire-and-forget with a warning on failure, and that turned a GitHub
# outage into repeated work: during a run of 503s, #1227's transition to
# needs-human silently failed, the issue stayed in qa:triage, the orchestrator
# re-dispatched it, and the curator split it THREE times — creating sub-issues on
# each pass. A state machine whose transitions can silently not happen is not a
# state machine.
#
# So: retry, then read back and confirm. If it still has not landed, say so loudly
# — the caller's own logic (and the orchestrator's dispatch) depends on it.
set_state() {
  local issue="$1" state="$2"
  local remove attempt actual
  # Remove every qa:* label except the one being set.
  remove=$(printf '%s' "$ALL_QA_LABELS" | tr ',' '\n' | grep -vxF "$state" | paste -sd, -)

  local read_ok=0
  for attempt in 1 2 3 4; do
    gh issue edit "$issue" --repo "$REPO" \
      --add-label "$state" --remove-label "$remove" >/dev/null 2>&1

    # Read back. GitHub is eventually consistent, so give it a moment first.
    sleep 2
    actual=$(get_state "$issue")
    [ "$actual" = "$state" ] && return 0
    [ -n "$actual" ] && read_ok=1

    [ "$attempt" -lt 4 ] && sleep $((attempt * 4))
  done

  # An unreadable state is NOT the same as a wrong state, and conflating them
  # produces false alarms during an API outage — the transition usually did land,
  # we just could not confirm it. Observed on #1232: reported as failed, actually
  # applied correctly.
  if [ "$read_ok" = "0" ]; then
    warn "não confirmei a transição de #$issue para '$state' (a API não respondeu à leitura)"
    warn "  a etiqueta provavelmente foi aplicada; o ciclo seguinte relê o estado real"
    return 0
  fi

  warn "TRANSIÇÃO FALHOU: #$issue continua em '$actual' e não em '$state'"
  warn "  o orquestrador vai voltar a despachar este issue — risco de trabalho repetido"
  return 1
}

# Read the single qa:* state label of an issue ("" when it has none).
get_state() {
  local issue="$1"
  gh issue view "$issue" --repo "$REPO" --json labels \
    --jq '[.labels[].name] | map(select(startswith("qa:"))) | .[0] // ""' 2>/dev/null || echo ""
}

# Add a label via the REST API, not `gh pr edit --add-label`.
#
# `gh pr edit` resolves project cards over GraphQL on the way through, and on this
# repo that fails outright: "Projects (classic) is being deprecated ...
# (repository.pullRequest.projectCards)". The label is then never applied and gh
# reports failure for a reason unrelated to labelling.
#
# That silently blocked the dev->main promotion PR: promote.sh believed it had set
# `release:patch`, pr-governance found no release label, and the PR sat BLOCKED with
# four verified fixes stranded behind it. The issues endpoint works for PRs too —
# GitHub treats them as issues for labelling.
add_label_api() {
  local number="$1" label="$2"
  gh api -X POST "repos/$REPO/issues/$number/labels" \
    -f "labels[]=$label" >/dev/null 2>&1
}

# Open a PR via the REST API, echoing its number. Same reason as add_label_api:
# `gh pr create` resolves project cards over GraphQL and dies on this repo with a
# Projects-classic deprecation error, so the PR is never opened even though the
# branch was pushed successfully.
#
# That cost real work twice. #1241 and #1242 were fully implemented by the
# fallback — 12 and 20 files, tests passing — pushed to their branches, and then
# escalated to needs-human with "PR não criado", where they sat for hours. The code
# was fine and on the remote the whole time; only the announcement failed.
create_pr_api() {
  local head="$1" base="$2" title="$3" body="$4"
  local resp num
  resp=$(gh api -X POST "repos/$REPO/pulls" \
           -f title="$title" -f head="$head" -f base="$base" -f body="$body" 2>&1)
  num=$(printf '%s' "$resp" | jq -r '.number // empty' 2>/dev/null)
  if [ -n "$num" ]; then printf '%s' "$num"; return 0; fi
  # An existing PR for this head is success, not failure.
  num=$(gh api "repos/$REPO/pulls?head=${REPO%%/*}:$head&base=$base&state=open" \
        --jq '.[0].number // empty' 2>/dev/null)
  if [ -n "$num" ]; then printf '%s' "$num"; return 0; fi
  warn "não abri PR $head -> $base: $(printf '%s' "$resp" | jq -r '.message // .' 2>/dev/null | head -1)"
  return 1
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
# True when the last agent on this slot ran on the FALLBACK engine rather than the
# subscription. A role that produced no verdict on the fallback must not be
# treated as "this issue defeated the pipeline": the fallback model is materially
# weaker (observed erroring then timing out on the curator role), so a temporary
# quota outage would otherwise park real work on needs-human permanently. Callers
# leave the issue in place and let it retry once the subscription returns.
agent_used_fallback() {
  local slot="${1:-main}"
  grep -q '^ollama/' "/tmp/monthy-budget-agent.$slot.engine" 2>/dev/null
}

# Standard handling for "the agent produced no verdict". Returns 0 when the caller
# should ESCALATE (real failure), 1 when it should leave the issue alone for a
# later retry.
#
# Two things look identical from the outside — no verdict file — and neither is the
# issue's fault:
#   * the fallback engine ran and could not finish (weaker model);
#   * the run never started at all because the lock slot was busy (exit 75).
# The second happens whenever the orchestrator is restarted while an agent is still
# mid-run: the old agent lives in its own process group and keeps the lock, so the
# new orchestrator's first dispatch aborts instantly. Escalating that to needs-human
# means a restart silently damages whatever issue happened to be next in line —
# observed on #1209, failed and escalated in 11 seconds.
no_verdict_is_real_failure() {
  local slot="${1:-main}" rc="${2:-}"

  if [ "$rc" = "75" ]; then
    warn "sem veredicto porque o slot '$slot' estava ocupado (exit 75) — não escalo"
    return 1
  fi
  if agent_used_fallback "$slot"; then
    warn "sem veredicto mas o motor era o fallback — não escalo, fica para nova tentativa"
    return 1
  fi
  return 0
}

# ── The UI tester ──────────────────────────────────────────────────────────
#
# Build a branch, serve it, and drive the real app against an issue's acceptance
# criteria. TWO stages call this: the pre-merge gate (on the PR's own branch,
# before anything is integrated) and the post-merge verifier (on `dev`, after).
#
# It is ONE function on purpose. The two stages ask the same question — "is the
# defect actually gone in the running app?" — and the moment they ask it with two
# copies of the prompt, the copies drift: one gets a sharper rubric, the other a
# stricter verdict schema, and a fix starts passing one gate and failing the other
# for reasons that have nothing to do with the code. Only the framing sentence
# differs, and that arrives as $6.
#
# The CALLER owns routing, because the two stages route differently: a pre-merge
# failure leaves the PR open, a post-merge failure leaves broken code in dev.
# The return code is the routing input:
#
#   0  verdict written to $4
#   1  environment failed (build, serve or toolkit) — nobody's fault, retry later
#   2  no verdict AND the run itself was degraded (no quota, slot taken)
#   3  no verdict on a healthy run — the tester had its chance and produced nothing
#
# Sets UI_TESTER_SCRATCH and UI_TESTER_LOG for the caller to quote in comments.
UI_TESTER_SCRATCH=""
UI_TESTER_LOG=""

run_ui_tester() {
  local issue="$1" branch="$2" port="$3" verdict_file="$4" stage="$5" stage_context="$6"
  local app_url="http://127.0.0.1:$port"
  local qa_tools="${TEAM_QA_TOOLS:-$HOME/Documentos/monthy-budget-qa-tools}"
  local model="${UI_TESTER_MODEL:-sonnet}"
  local prompt="/tmp/$stage-prompt-$issue.txt"

  UI_TESTER_SCRATCH="$LOG_DIR/$stage-$issue-$(date +%H%M%S)"
  UI_TESTER_LOG="$LOG_DIR/$stage-$issue.log"
  mkdir -p "$UI_TESTER_SCRATCH" 2>/dev/null || true

  log "a garantir que a app de '$branch' está a servir e actualizada (porta $port)..."
  bash "$TEAM_SCRIPT_DIR/serve-app.sh" "$branch" --port "$port" || {
    warn "não consegui compilar/servir '$branch'"; return 1; }

  # Serving is not running. The build can succeed and the server still not answer,
  # and a tester pointed at a dead URL reports the defect as present — condemning a
  # fix for an environment fault.
  curl -fsS -o /dev/null --max-time 5 "$app_url/" || {
    warn "$app_url não responde"; return 1; }

  bash "$TEAM_SCRIPT_DIR/qa-tools-setup.sh" >>"$LOG_DIR/$stage-$issue.toolkit.log" 2>&1 || {
    warn "toolkit de browser não ficou pronto"; return 1; }

  local issue_json
  issue_json=$(gh issue view "$issue" --repo "$REPO" \
    --json title,body,comments --jq '
    "# " + .title + "\n\n" + (.body // "") + "\n\n## Comentários\n\n" +
    (if (.comments | length) > 0 then
       ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
     else "(sem comentários)" end)' 2>/dev/null) || {
    warn "não consegui ler o issue #$issue"; return 1; }

  # The framing paragraph is substituted with awk, not sed: it is multi-line and
  # contains backticks and pipes, all of which either break a sed s|| expression
  # or get silently mangled by it. A mangled framing is worse than an obvious
  # failure — the tester would still run, just against the wrong premise.
  local ctx_file="/tmp/$stage-ctx-$issue.txt"
  printf '%s\n' "$stage_context" > "$ctx_file"

  {
    awk -v ctx="$ctx_file" '
      /__STAGE_CONTEXT__/ { while ((getline line < ctx) > 0) print line; close(ctx); next }
      { print }
    ' "$TEAM_SCRIPT_DIR/verify-prompt.md"
    echo ""
    echo "---"
    echo ""
    echo "# O issue a verificar"
    echo ""
    echo "Os \"Critérios de aceitação\" e o \"Como testar\" estão nos comentários do"
    echo "curator abaixo. O relato do implementador diz o que ele afirma ter feito —"
    echo "confirma na app, não acredites."
    echo ""
    printf '%s\n' "$issue_json"
  } | sed -e "s|__VERDICT_PATH__|$verdict_file|g" \
          -e "s|__APP_URL__|$app_url|g" \
          -e "s|__BRANCH__|$branch|g" \
          -e "s|__SCRATCH__|$UI_TESTER_SCRATCH|g" \
          -e "s|__QA_TOOLS__|$qa_tools|g" > "$prompt"
  rm -f "$ctx_file"

  rm -f "$verdict_file"
  local rc
  AGENT_SLOT=main CLAUDE_MODEL="$model" \
    AGENT_ADD_DIRS="$UI_TESTER_SCRATCH:$qa_tools" \
    bash "$TEAM_SCRIPT_DIR/run-agent.sh" "$prompt" "$qa_tools" "${UI_TESTER_TIMEOUT:-1800}" \
    > "$UI_TESTER_LOG" 2>&1; rc=$?

  [ -f "$verdict_file" ] && return 0
  no_verdict_is_real_failure main "$rc" || return 2
  return 3
}

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
