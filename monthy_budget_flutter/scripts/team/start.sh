#!/bin/bash
# start.sh — run the pipeline in a detached tmux session so it survives the
# terminal closing, and so you can attach to watch it work.
#
# Usage: start.sh [--loops N] [--attach] [--stop] [--status] [-- <orchestrator args>]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="start"

SESSION="${TEAM_SESSION:-monthy-qa}"
ACTION="start"
declare -a ORCH_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --attach) ACTION="attach"; shift ;;
    --stop) ACTION="stop"; shift ;;
    --status) ACTION="status"; shift ;;
    --) shift; ORCH_ARGS+=("$@"); break ;;
    *) ORCH_ARGS+=("$1"); shift ;;
  esac
done

case "$ACTION" in
  attach)
    exec tmux attach -t "$SESSION"
    ;;
  stop)
    tmux kill-session -t "$SESSION" 2>/dev/null && log "sessão '$SESSION' terminada" \
      || log "sessão '$SESSION' não estava a correr"

    # Killing the tmux session is NOT enough. run-agent.sh puts each agent in its
    # own process group via setsid precisely so it can be killed as a unit — which
    # also means it SURVIVES the session dying, and keeps holding its lock slot.
    #
    # The next orchestrator's first dispatch then aborts instantly with exit 75
    # ("slot já tem um agente a correr"), produces no verdict, and — before this was
    # handled — escalated a perfectly good issue to needs-human. Observed on #1209:
    # failed and escalated 11 seconds after a restart.
    for pgidfile in /tmp/monthy-budget-agent.*.lock.pgid; do
      [ -f "$pgidfile" ] || continue
      pgid=$(cat "$pgidfile" 2>/dev/null || echo "")
      if [ -n "$pgid" ] && kill -0 -"$pgid" 2>/dev/null; then
        log "a terminar a árvore do agente (pgid $pgid, $(basename "$pgidfile" .lock.pgid))"
        kill -TERM -"$pgid" 2>/dev/null || true
        sleep 2
        kill -KILL -"$pgid" 2>/dev/null || true
      fi
      rm -f "$pgidfile"
    done

    # Belt and braces: kill whatever still holds a lock file even if no pgid file
    # points at it. An agent that outlived its parent has no pgid record (the exit
    # trap removes it), so the lock file itself is the only remaining handle on it.
    for lock in /tmp/monthy-budget-agent.*.lock; do
      [ -f "$lock" ] || continue
      holders=$(fuser "$lock" 2>/dev/null | tr -s ' ' '\n' | grep -E '^[0-9]+$' || true)
      for pid in $holders; do
        log "a terminar processo órfão $pid que ainda segura $(basename "$lock")"
        kill -TERM "$pid" 2>/dev/null || true
      done
      [ -n "$holders" ] && { sleep 2; for pid in $holders; do kill -KILL "$pid" 2>/dev/null || true; done; }
    done
    bash "$SCRIPT_DIR/serve-app.sh" "$PROD_BRANCH" --stop 2>/dev/null || true
    bash "$SCRIPT_DIR/serve-app.sh" "$BASE_BRANCH" --stop 2>/dev/null || true
    exit 0
    ;;
  status)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      echo "orquestrador: a correr (tmux '$SESSION')"
    else
      echo "orquestrador: parado"
    fi
    bash "$SCRIPT_DIR/serve-app.sh" "$PROD_BRANCH" --status 2>/dev/null || true
    bash "$SCRIPT_DIR/serve-app.sh" "$BASE_BRANCH" --status 2>/dev/null || true
    echo "loops concluídos: $(cat "$STATE_DIR/loops-completed" 2>/dev/null || echo 0)"
    echo -n "issues por estado: "
    for s in qa:triage qa:ready qa:wip qa:review qa:premerge qa:verify qa:blocked-impl qa:blocked-spec qa:needs-human; do
      n=$(gh issue list --repo "$REPO" --label "$s" --state open --json number --jq 'length' 2>/dev/null || echo 0)
      [ "$n" != "0" ] && printf '%s=%s ' "$s" "$n"
    done
    echo
    exit 0
    ;;
esac

if tmux has-session -t "$SESSION" 2>/dev/null; then
  log "sessão '$SESSION' já está a correr. Usa --attach, ou --stop primeiro."
  exit 1
fi

LOGFILE="$LOG_DIR/orchestrator-$(date +%Y%m%d-%H%M%S).log"
log "a arrancar em tmux '$SESSION'; log: $LOGFILE"

# `tee` into a file as well as the pane: once a pane closes there is no way to
# inspect what happened, and this thing runs for hours unattended.
tmux new-session -d -s "$SESSION" -n orchestrator \
  "cd '$SCRIPT_DIR' && bash orchestrator.sh ${ORCH_ARGS[*]:-} 2>&1 | tee '$LOGFILE'; echo '--- TERMINOU ---'; read -r"

cat <<EOF
Pipeline a correr.
  Ver:      tmux attach -t $SESSION      (ou: start.sh --attach)
  Estado:   bash scripts/team/start.sh --status
  Log:      tail -f $LOGFILE
  Parar:    bash scripts/team/start.sh --stop
EOF
