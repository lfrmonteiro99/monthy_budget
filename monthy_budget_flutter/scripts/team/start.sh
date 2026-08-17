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
    for s in qa:triage qa:ready qa:wip qa:review qa:verify qa:blocked-impl qa:blocked-spec qa:needs-human; do
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
