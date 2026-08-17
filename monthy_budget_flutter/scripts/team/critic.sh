#!/bin/bash
# critic.sh — the QA CRITIC. Drives the running app in a browser across several
# testing dimensions in parallel, then files what it found as GitHub issues.
#
# The critic tests the PRODUCTION branch (main): its job is to find what is wrong
# with the app as shipped. The VERIFIER (verify.sh) is the one that re-tests
# fixes on `dev`.
#
# Dimension testers run CONCURRENTLY because they only read the app and write a
# findings file each — they cannot conflict. Filing is then done ONCE,
# serially, from all their findings together, so two testers who noticed the
# same thing produce one issue and not two.
#
# Usage: critic.sh [--dimensions a,b,c] [--branch main] [--concurrency N] [--no-serve]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="critic"

ALL_DIMS="functional layout design ux a11y i18n perf console data"
DIMS="$ALL_DIMS"
BRANCH="$PROD_BRANCH"
CONCURRENCY="${CRITIC_CONCURRENCY:-3}"
DO_SERVE=1
TIMEOUT_S="${CRITIC_TIMEOUT:-1800}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dimensions) DIMS=$(printf '%s' "$2" | tr ',' ' '); shift 2 ;;
    --dimensions=*) DIMS=$(printf '%s' "${1#--dimensions=}" | tr ',' ' '); shift ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --branch=*) BRANCH="${1#--branch=}"; shift ;;
    --concurrency) CONCURRENCY="$2"; shift 2 ;;
    --no-serve) DO_SERVE=0; shift ;;
    *) shift ;;
  esac
done

case "$BRANCH" in
  "$PROD_BRANCH") APP_PORT="$PORT_PROD" ;;
  "$BASE_BRANCH") APP_PORT="$PORT_DEV" ;;
  *) APP_PORT=7410 ;;
esac
APP_URL="http://127.0.0.1:$APP_PORT"

RUN_ID="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="$LOG_DIR/critic-$RUN_ID"
mkdir -p "$RUN_DIR"

QA_TOOLS="${TEAM_QA_TOOLS:-$HOME/Documentos/monthy-budget-qa-tools}"

log "run=$RUN_ID branch=$BRANCH url=$APP_URL dims=[$DIMS] concorrência=$CONCURRENCY"

# ── 1. App under test ──────────────────────────────────────────────────────
if [ "$DO_SERVE" = "1" ]; then
  log "a garantir que a app de '$BRANCH' está a servir..."
  if ! bash "$SCRIPT_DIR/serve-app.sh" "$BRANCH" --port "$APP_PORT"; then
    log "ERRO: não consegui servir a app — sem app não há QA. A abortar."
    exit 1
  fi
fi

if ! curl -fsS -o /dev/null --max-time 5 "$APP_URL/"; then
  log "ERRO: $APP_URL não responde. A abortar."
  exit 1
fi

# ── 2. Browser toolkit ─────────────────────────────────────────────────────
# The toolkit lives in its own npm project: the tester scripts must run from
# there for `import 'playwright'` to resolve. We copy the current version of the
# driver in on every run so the harness in git stays the single source of truth.
if ! bash "$SCRIPT_DIR/qa-tools-setup.sh" >>"$RUN_DIR/toolkit.log" 2>&1; then
  log "ERRO: preparação do toolkit de browser falhou — ver $RUN_DIR/toolkit.log"
  exit 1
fi

# ── 2b. Boot gate ──────────────────────────────────────────────────────────
# Check ONCE, cheaply, that the app actually reaches its authenticated shell
# before fanning out. If the build is broken, every tester would independently
# discover the same grey rectangle and file it as a blocker in its own words —
# nine agents burning quota to produce one real finding plus eight artefacts.
BOOT_DIR="$RUN_DIR/bootcheck"
if node "$QA_TOOLS/probe.mjs" --url "$APP_URL" --out "$BOOT_DIR" --tabs home \
     >"$RUN_DIR/bootcheck.log" 2>&1; then :; fi
BOOTED=$(jq -r '.bootedIntoApp // false' "$BOOT_DIR/report.json" 2>/dev/null || echo false)

if [ "$BOOTED" != "true" ]; then
  log "A APP NÃO ARRANCA em $APP_URL — não vale a pena lançar os testers"
  BOOT_LABELS=$(jq -r '[(.screens.boot.labels // [])[:15][]] | join(" | ")' "$BOOT_DIR/report.json" 2>/dev/null || echo "")
  BOOT_ERRS=$(jq -r '[((.diagnostics.consoleErrors // []) + (.diagnostics.pageErrors // []))[:6][]] | join("\n")' "$BOOT_DIR/report.json" 2>/dev/null || echo "")
  TITLE="A app não arranca no build de QA de \`$BRANCH\` (ecrã vazio)"

  # Only file it if it is not already open, otherwise every cycle adds another.
  if gh issue list --repo "$REPO" --state open --search "in:title app não arranca" \
       --json number --jq 'length' 2>/dev/null | grep -qx 0; then
    gh issue create --repo "$REPO" --title "$TITLE" \
      --label "critic,$L_TRIAGE,sev:blocker,dim:console" \
      --body "$(cat <<EOF
> Detectado pelo QA critic antes de lançar os testers.

## O que está mal

O build de QA de \`$BRANCH\` não chega à shell autenticada. Nenhum teste de QA é
possível neste estado, por isso esta corrida foi interrompida sem lançar as
restantes dimensões.

## Observado

Labels no arranque: \`${BOOT_LABELS:-(nenhum — a árvore semântica está vazia)}\`

Erros de consola / página:

\`\`\`
${BOOT_ERRS:-(nenhum registado)}
\`\`\`

## Como reproduzir

1. \`bash scripts/team/serve-app.sh $BRANCH\`
2. \`cd $QA_TOOLS && node probe.mjs --url $APP_URL --out /tmp/boot\`
3. \`bootedIntoApp\` vem \`false\`.

## Prova

- \`$BOOT_DIR/report.json\`
- \`$BOOT_DIR/boot.png\`

---
- Testado em: branch \`$BRANCH\`
- Corrida do critic: \`$RUN_ID\`
EOF
)" >/dev/null 2>&1 && log "issue de blocker de arranque criado"
  else
    log "blocker de arranque já está aberto — não duplico"
  fi
  exit 0
fi
log "a app arranca — a lançar os testers"

# The repo checkout the testers may read (design docs, ARB files, service code).
REPO_PKG="$WT_ROOT/serve-$(printf '%s' "$BRANCH" | tr -c 'a-zA-Z0-9._-' '-')/$FLUTTER_SUBDIR"
[ -d "$REPO_PKG" ] || REPO_PKG="$TEAM_ROOT/$FLUTTER_SUBDIR"

# ── 3. Existing issues, for de-duplication ─────────────────────────────────
OPEN_ISSUES=$(gh issue list --repo "$REPO" --state open --limit 300 \
  --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null || echo "")
ISSUE_COUNT=$(printf '%s' "$OPEN_ISSUES" | grep -c . || true)
log "issues abertos a evitar duplicar: $ISSUE_COUNT"

# ── 4. Fan out the dimension testers ───────────────────────────────────────
run_dimension() {
  local dim="$1"
  local scratch="$RUN_DIR/$dim"
  local verdict="$VERDICT_DIR/critic-$dim.json"
  local prompt="$RUN_DIR/prompt-$dim.txt"
  local dim_file="$SCRIPT_DIR/dimensions/$dim.md"

  mkdir -p "$scratch"
  # STALE: delete before the run. If the agent dies without writing, an
  # inherited verdict from a previous run would be read as this run's result.
  rm -f "$verdict"

  {
    cat "$SCRIPT_DIR/critic-prompt.md"
    echo ""
    echo "---"
    echo ""
    if [ -f "$dim_file" ]; then
      cat "$dim_file"
    else
      echo "## Dimensão: $dim"
      echo "(sem briefing específico — testa esta dimensão pelo teu próprio critério)"
    fi
    echo ""
    echo "---"
    echo ""
    echo "# Contexto desta corrida"
    echo ""
    echo "- App a testar: $APP_URL (branch \`$BRANCH\`)"
    echo "- Código da app (leitura): $REPO_PKG"
    echo "- Toolkit de browser: $QA_TOOLS"
    echo "- A tua pasta de trabalho: $scratch"
    echo ""
    echo "## Issues abertos — NÃO duplicar"
    echo ""
    if [ -n "$OPEN_ISSUES" ]; then printf '%s\n' "$OPEN_ISSUES"; else echo "(nenhum)"; fi
  } | sed -e "s|__APP_URL__|$APP_URL|g" \
          -e "s|__SCRATCH__|$scratch|g" \
          -e "s|__QA_TOOLS__|$QA_TOOLS|g" \
          -e "s|__REPO_PKG__|$REPO_PKG|g" \
          -e "s|__DIMENSION__|$dim|g" \
          -e "s|__VERDICT_PATH__|$verdict|g" > "$prompt"

  # Each tester gets its own lock slot: they are read-only against the app and
  # must be free to run at the same time.
  AGENT_SLOT="critic-$dim" \
  AGENT_ADD_DIRS="$scratch:$QA_TOOLS:$RUN_DIR" \
  CLAUDE_MODEL="${CRITIC_MODEL:-sonnet}" \
  bash "$SCRIPT_DIR/run-agent.sh" "$prompt" "$QA_TOOLS" "$TIMEOUT_S" \
    > "$RUN_DIR/$dim.log" 2>&1
  local rc=$?

  if [ -f "$verdict" ]; then
    local n; n=$(jq '(.findings // []) | length' "$verdict" 2>/dev/null || echo "?")
    log "  [$dim] rc=$rc findings=$n"
  else
    log "  [$dim] rc=$rc SEM VEREDICTO (ver $RUN_DIR/$dim.log)"
  fi
}

log "a lançar testers..."
declare -a PIDS=()
for dim in $DIMS; do
  # Throttle: browsers are heavy and the machine is shared.
  while [ "$(jobs -rp | wc -l)" -ge "$CONCURRENCY" ]; do sleep 5; done
  run_dimension "$dim" &
  PIDS+=("$!")
  sleep 2
done

for pid in "${PIDS[@]}"; do wait "$pid" 2>/dev/null || true; done
log "todos os testers terminaram"

# ── 5. File the findings (serialized, de-duplicated) ───────────────────────
VERDICTS=()
for dim in $DIMS; do
  [ -f "$VERDICT_DIR/critic-$dim.json" ] && VERDICTS+=("$VERDICT_DIR/critic-$dim.json")
done

if [ "${#VERDICTS[@]}" -eq 0 ]; then
  log "nenhum veredicto escrito — nada para reportar"
  exit 0
fi

log "a arquivar findings de ${#VERDICTS[@]} dimensão(ões)..."
python3 "$SCRIPT_DIR/file-findings.py" \
  --repo "$REPO" \
  --branch "$BRANCH" \
  --run-id "$RUN_ID" \
  --run-dir "$RUN_DIR" \
  "${VERDICTS[@]}" 2>&1 | tee -a "$RUN_DIR/filing.log"

for v in "${VERDICTS[@]}"; do rm -f "$v"; done
log "run=$RUN_ID concluído. Logs: $RUN_DIR"
