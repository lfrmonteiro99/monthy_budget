#!/bin/bash
# run-agent.sh — runs ONE agent: the Claude Code harness plus a prompt.
#
# Primary path is the local `claude` CLI on the user's subscription. When that
# subscription is out of usage we fall back to running the same harness against
# an Ollama Cloud model (`ollama launch claude`), which is the arrangement the
# sibling project uses. The harness — and therefore the tools the agent has —
# is identical either way; only the model behind it changes.
#
# Usage: run-agent.sh <prompt-file> <workdir> [timeout_s]
#
# Environment:
#   AGENT_SLOT          lock scope. Roles that write to git/GitHub share the
#                       default slot so only one of them ever runs at a time.
#                       Read-only testers pass their own slot to run in parallel.
#   AGENT_ALLOWED_TOOLS --allowedTools value (default: a read/write/bash set)
#   AGENT_ADD_DIRS      colon-separated extra --add-dir paths
#   CLAUDE_MODEL        default: sonnet
#   FALLBACK_MODEL      default: deepseek-v4-flash:cloud
#   AGENT_FORCE_FALLBACK=1  skip the subscription entirely (for testing)
set -uo pipefail

PROMPT_FILE="${1:?ficheiro de prompt obrigatorio}"
WORKDIR="${2:?workdir obrigatorio}"
TIMEOUT_S="${3:-900}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="run-agent"

CLAUDE_MODEL="${CLAUDE_MODEL:-sonnet}"
FALLBACK_MODEL="${FALLBACK_MODEL:-deepseek-v4-flash:cloud}"
AGENT_SLOT="${AGENT_SLOT:-main}"

[ -f "$PROMPT_FILE" ] || { echo "ERRO: prompt não existe: $PROMPT_FILE" >&2; exit 1; }
[ -d "$WORKDIR" ]     || { echo "ERRO: workdir não existe: $WORKDIR" >&2; exit 1; }

# ── Lock ───────────────────────────────────────────────────────────────────
# `-w 0`: if this slot is already busy, ABORT NOW rather than queue. Waiting is
# what let a timed-out agent stay alive while the next cycle started another one
# on top of it (two live agents on the same repo, measured).
LOCK="/tmp/monthy-budget-agent.$AGENT_SLOT.lock"
exec 9>"$LOCK"
if ! flock -w 0 9; then
  echo "[run-agent] ABORTADO: slot '$AGENT_SLOT' já tem um agente a correr" >&2
  exit 75
fi

# `setsid` puts the agent and every descendant in their own process group, and
# we record the leader pid (= pgid). That is what lets the orchestrator kill
# exactly OUR agent tree later. Do not reach for `pkill -f claude`: it also
# kills whatever `claude` the user happens to be running in another terminal.
PGID_FILE="$LOCK.pgid"
cleanup() { rm -f "$PGID_FILE"; }
trap cleanup EXIT

COOLDOWN_FILE="$STATE_DIR/claude-usage-cooldown"

# True when a previous run hit the usage limit recently. Without this we would
# spend one doomed request per cycle re-discovering that the quota is gone.
in_cooldown() {
  [ -f "$COOLDOWN_FILE" ] || return 1
  local until_ts now
  until_ts=$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)
  now=$(date +%s)
  [ "$now" -lt "$until_ts" ]
}

start_cooldown() {
  local mins="${1:-45}"
  echo $(( $(date +%s) + mins * 60 )) > "$COOLDOWN_FILE"
  echo "[run-agent] cooldown da subscrição: ${mins}min" >&2
}

# Distinguish "out of quota" from "the agent failed at its task". Only the
# former justifies burning the fallback model; the latter must surface as a
# failure so the caller marks the issue instead of silently retrying forever.
is_usage_exhausted() {
  local out="$1"
  grep -qiE \
    'usage limit|rate.?limit|quota (exceeded|reached)|too many requests|429|insufficient (quota|credit)|upgrade to (pro|max)|resets? at' \
    <<<"$out"
}

build_add_dirs() {
  local -a args=()
  # The verdict is written OUTSIDE the working tree, so the harness has to be
  # told that directory is in scope — otherwise it refuses the Write and the
  # agent finishes having recorded nothing, which is the exact failure this
  # whole design exists to prevent.
  args+=(--add-dir "$VERDICT_DIR")
  if [ -n "${AGENT_ADD_DIRS:-}" ]; then
    local IFS=':'
    for d in $AGENT_ADD_DIRS; do
      [ -n "$d" ] && args+=(--add-dir "$d")
    done
  fi
  printf '%s\n' "${args[@]}"
}

DEFAULT_TOOLS='Read,Write,Edit,Glob,Grep,Bash,TodoWrite'
ALLOWED_TOOLS="${AGENT_ALLOWED_TOOLS:-$DEFAULT_TOOLS}"

mapfile -t ADD_DIR_ARGS < <(build_add_dirs)

run_harness() {
  local kind="$1" model="$2"; shift 2
  local -a cmd=("$@")

  echo "[run-agent] motor=$kind modelo=$model workdir=$WORKDIR timeout=${TIMEOUT_S}s" >&2

  local out_file
  out_file=$(mktemp "/tmp/run-agent-$AGENT_SLOT.XXXXXX.out")

  # -k 30: if SIGTERM doesn't kill it, SIGKILL follows 30s later. Nothing is
  # left hanging on to the lock.
  setsid timeout -k 30 "$TIMEOUT_S" "${cmd[@]}" > "$out_file" 2>&1 &
  local pid=$!
  echo "$pid" > "$PGID_FILE"
  # If THIS script is killed, take the whole group down — no orphans.
  trap 'kill -TERM -"'"$pid"'" 2>/dev/null; cleanup' TERM INT

  wait "$pid"
  local rc=$?
  AGENT_OUTPUT=$(cat "$out_file" 2>/dev/null || echo "")
  rm -f "$out_file"
  # Surface the agent's own transcript to the caller's log.
  printf '%s\n' "$AGENT_OUTPUT"
  return $rc
}

PROMPT="$(cat "$PROMPT_FILE")"
RC=1
USED=""

# ── 1. Subscription (claude CLI) ───────────────────────────────────────────
if [ "${AGENT_FORCE_FALLBACK:-0}" != "1" ] && ! in_cooldown && command -v claude >/dev/null 2>&1; then
  USED="claude/$CLAUDE_MODEL"
  run_harness "claude" "$CLAUDE_MODEL" \
    claude -p "$PROMPT" \
      --model "$CLAUDE_MODEL" \
      "${ADD_DIR_ARGS[@]}" \
      --permission-mode acceptEdits \
      --allowedTools "$ALLOWED_TOOLS" \
      --strict-mcp-config --mcp-config '{"mcpServers":{}}'
  RC=$?

  if [ "$RC" -ne 0 ] && is_usage_exhausted "${AGENT_OUTPUT:-}"; then
    echo "[run-agent] subscrição sem usage — a passar para o fallback" >&2
    start_cooldown 45
    RC=1
    USED=""
  fi
else
  if in_cooldown; then echo "[run-agent] subscrição em cooldown — fallback directo" >&2; fi
fi

# ── 2. Fallback (Ollama Cloud model behind the same harness) ───────────────
if [ -z "$USED" ]; then
  # Credential: explicit env wins, then a local override file, then the sibling
  # project's .env, which is where this key is maintained on this machine.
  if [ -z "${OLLAMA_API_KEY:-}" ]; then
    for src in "$HOME/.config/monthy-budget-team/env" "$HOME/Documentos/companion-chat/.env"; do
      if [ -f "$src" ]; then
        key=$(grep -E '^(OLLAMA_API_KEY|MANAGED_CHAT_API_KEY)=' "$src" 2>/dev/null | head -1 | cut -d= -f2-)
        if [ -n "$key" ]; then export OLLAMA_API_KEY="$key"; break; fi
      fi
    done
  fi

  if ! command -v ollama >/dev/null 2>&1 || [ -z "${OLLAMA_API_KEY:-}" ]; then
    echo "[run-agent] SEM FALLBACK: ollama ou OLLAMA_API_KEY em falta" >&2
    exit 76
  fi

  export OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-https://cloud.ollama.ai}"
  # The fallback model isn't in Claude Code's model table; without these it
  # warns on stderr every single run.
  export CLAUDE_CODE_MAX_CONTEXT_TOKENS="${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-200000}"
  export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1

  USED="ollama/$FALLBACK_MODEL"
  run_harness "ollama" "$FALLBACK_MODEL" \
    ollama launch claude --model "$FALLBACK_MODEL" --yes -- \
      -p "$PROMPT" \
      "${ADD_DIR_ARGS[@]}" \
      --permission-mode acceptEdits \
      --allowedTools "$ALLOWED_TOOLS" \
      --strict-mcp-config --mcp-config '{"mcpServers":{}}'
  RC=$?
fi

echo "[run-agent] fim: motor=$USED rc=$RC" >&2
exit "$RC"
