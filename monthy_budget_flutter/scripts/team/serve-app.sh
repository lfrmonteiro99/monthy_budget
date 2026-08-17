#!/bin/bash
# serve-app.sh — build the app for a branch in QA mode and serve it over HTTP,
# so the testers can drive the real UI in a headless browser.
#
#   main -> port 7401   (what the CRITIC tests: production code)
#   dev  -> port 7402   (what the VERIFIER tests: production code + merged fixes)
#
# Usage: serve-app.sh <branch> [--port N] [--force] [--stop] [--status]
#
# The build is cached against the branch head sha: re-running when nothing has
# changed is a no-op, so the orchestrator can call this every cycle cheaply.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="serve"

BRANCH="${1:?branch obrigatorio}"; shift || true
PORT=""
FORCE=0
ACTION="start"

while [ $# -gt 0 ]; do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --port=*) PORT="${1#--port=}"; shift ;;
    --force) FORCE=1; shift ;;
    --stop) ACTION="stop"; shift ;;
    --status) ACTION="status"; shift ;;
    *) shift ;;
  esac
done

if [ -z "$PORT" ]; then
  case "$BRANCH" in
    "$PROD_BRANCH") PORT="$PORT_PROD" ;;
    "$BASE_BRANCH") PORT="$PORT_DEV" ;;
    *) PORT=7410 ;;
  esac
fi

SLUG=$(printf '%s' "$BRANCH" | tr -c 'a-zA-Z0-9._-' '-')
WT="$WT_ROOT/serve-$SLUG"
PID_FILE="$STATE_DIR/serve-$SLUG.pid"
SHA_FILE="$STATE_DIR/serve-$SLUG.sha"
BUILD_LOG="$LOG_DIR/serve-$SLUG.build.log"

server_alive() {
  [ -f "$PID_FILE" ] || return 1
  local pid; pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

stop_server() {
  if server_alive; then
    local pid; pid=$(cat "$PID_FILE")
    log "a parar servidor de '$BRANCH' (pid $pid)"
    kill -TERM "$pid" 2>/dev/null || true
    sleep 1
    kill -KILL "$pid" 2>/dev/null || true
  fi
  rm -f "$PID_FILE"
}

http_ok() {
  curl -fsS -o /dev/null --max-time 5 "http://127.0.0.1:$PORT/" 2>/dev/null
}

case "$ACTION" in
  stop)
    stop_server
    log "parado"
    exit 0
    ;;
  status)
    if server_alive && http_ok; then
      echo "up branch=$BRANCH port=$PORT sha=$(cat "$SHA_FILE" 2>/dev/null || echo '?')"
      exit 0
    fi
    echo "down branch=$BRANCH port=$PORT"
    exit 1
    ;;
esac

# ── Resolve the branch head ────────────────────────────────────────────────
git -C "$TEAM_ROOT" fetch origin "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH" >/dev/null 2>&1 || true
HEAD_SHA=$(git -C "$TEAM_ROOT" rev-parse --verify --quiet "origin/$BRANCH" 2>/dev/null || echo "")
if [ -z "$HEAD_SHA" ]; then
  log "ERRO: branch '$BRANCH' não existe no remoto"
  exit 1
fi

CURRENT_SHA=$(cat "$SHA_FILE" 2>/dev/null || echo "")

if [ "$FORCE" = "0" ] && [ "$CURRENT_SHA" = "$HEAD_SHA" ] && server_alive && http_ok; then
  log "já a servir '$BRANCH' @ ${HEAD_SHA:0:8} em :$PORT — nada a fazer"
  exit 0
fi

log "a preparar '$BRANCH' @ ${HEAD_SHA:0:8} para :$PORT"
stop_server

# ── Fresh worktree at that sha ─────────────────────────────────────────────
# Always rebuilt from scratch: a stale worktree is how you end up serving code
# that no longer matches the sha you claim to be testing, and every finding the
# testers file against it is then unreproducible.
wt_remove "$WT"
WT_OUT=$(wt_checkout "$BRANCH" "serve-$SLUG") || { log "ERRO: checkout falhou"; exit 1; }
WT="$WT_OUT"
PKG="$WT/$FLUTTER_SUBDIR"

log "a instalar dependências..."
if ! ( cd "$PKG" && flutter pub get >>"$BUILD_LOG" 2>&1 && flutter gen-l10n >>"$BUILD_LOG" 2>&1 ); then
  log "ERRO: pub get / gen-l10n falhou — ver $BUILD_LOG"
  exit 1
fi

log "a compilar web em QA mode (pode levar alguns minutos)..."
# QA_MODE=true is what swaps the Supabase repositories for the local sqlite ones
# and bypasses the login gate, so the tester lands in the real authenticated app
# with deterministic seeded data instead of staring at a login screen.
if ! ( cd "$PKG" && flutter build web --release \
        --dart-define=QA_MODE=true \
        --dart-define=SUPABASE_URL=https://example.supabase.co \
        --dart-define=SUPABASE_ANON_KEY=qa-placeholder \
        >>"$BUILD_LOG" 2>&1 ); then
  log "ERRO: build web falhou — últimas linhas:"
  tail -30 "$BUILD_LOG" >&2
  exit 1
fi

if [ ! -f "$PKG/build/web/index.html" ]; then
  log "ERRO: build terminou sem index.html"
  exit 1
fi

# ── Serve ──────────────────────────────────────────────────────────────────
nohup python3 "$SCRIPT_DIR/qa_http_server.py" "$PKG/build/web" "$PORT" \
  >>"$LOG_DIR/serve-$SLUG.log" 2>&1 &
echo $! > "$PID_FILE"

for _ in $(seq 1 30); do
  if http_ok; then
    echo "$HEAD_SHA" > "$SHA_FILE"
    log "a servir '$BRANCH' @ ${HEAD_SHA:0:8} em http://127.0.0.1:$PORT"
    exit 0
  fi
  sleep 1
done

log "ERRO: servidor não respondeu em :$PORT"
stop_server
exit 1
