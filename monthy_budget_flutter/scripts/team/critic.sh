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

# RETRY, AND TELL A BAD BUILD APART FROM A BAD MOMENT.
#
# A single probe was enough to abort an entire sweep, and it did — twice today. The
# recorded causes were `net::ERR_NETWORK_CHANGED`, `WebAssembly compilation aborted:
# Network error` and `WebGL: CONTEXT_LOST_WEBGL`. None of those is an app defect: the
# first is the network interface moving under us, the second is its consequence while
# fetching the CanvasKit wasm, the third is the GPU context dying on a machine running
# at load 11 with fourteen chromium processes. The app served fine before and after.
#
# The cost of conflating the two was high. Both sweeps aborted without launching a
# single dimension, so the critic produced nothing at all for fifteen hours, and one
# run filed the blip as a sev:blocker issue that then went through curation, review
# and verification as if it were a defect.
#
# So: three attempts with a fresh browser, and only environmental patterns are treated
# as retryable. A genuinely broken build fails identically every time and still stops
# the run on the last attempt.
ENV_NOISE='ERR_NETWORK_CHANGED|CONTEXT_LOST_WEBGL|Response body loading was aborted|ERR_CONNECTION_RESET|ERR_INTERNET_DISCONNECTED'
BOOTED=false
for attempt in 1 2 3; do
  if node "$QA_TOOLS/probe.mjs" --url "$APP_URL" --out "$BOOT_DIR" --tabs home \
       >"$RUN_DIR/bootcheck.log" 2>&1; then :; fi
  BOOTED=$(jq -r '.bootedIntoApp // false' "$BOOT_DIR/report.json" 2>/dev/null || echo false)
  [ "$BOOTED" = "true" ] && break

  BOOT_ERRS_RAW=$(jq -r '[((.diagnostics.consoleErrors // []) + (.diagnostics.pageErrors // []) + (.diagnostics.consoleWarnings // []))[]] | join(" ")' \
    "$BOOT_DIR/report.json" 2>/dev/null || echo "")
  if printf '%s' "$BOOT_ERRS_RAW" | grep -qE "$ENV_NOISE"; then
    if [ "$attempt" -lt 3 ]; then
      log "arranque falhou por ruído de ambiente (tentativa $attempt/3) — a repetir em 20s"
      log "  $(printf '%s' "$BOOT_ERRS_RAW" | grep -oE "$ENV_NOISE" | sort -u | tr '\n' ' ')"
      sleep 20
      continue
    fi
    # Three environmental failures in a row is a broken machine, not a broken build.
    # Say that, and do NOT file an app defect for it.
    log "ARRANQUE IMPOSSÍVEL por ruído de ambiente em 3 tentativas — a abortar SEM arquivar issue"
    log "  causas: $(printf '%s' "$BOOT_ERRS_RAW" | grep -oE "$ENV_NOISE" | sort -u | tr '\n' ' ')"
    log "  as dimensões NÃO ficam marcadas como cobertas: este varrimento repete-se"
    exit 0
  fi
  # Not environmental — a real boot failure. No point retrying a deterministic one.
  break
done

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
> "$LOG_DIR/.filing.lock"

# Per-dimension timeout. The default is not enough for the widest briefs and a
# timeout loses the whole dimension: rc=124 means no verdict, and the salvage
# retry deliberately does not fire (an agent killed by the clock was genuinely
# still working, so repeating it just burns the same time again).
#
# `functional` is by far the largest brief — full CRUD, persistence across reload,
# and the propagation matrix across every dependent screen — and it timed out at
# 1800s on the first sweep. `data` recomputes money by hand and `i18n` walks four
# locales, so both are also above baseline.
dim_timeout() {
  case "$1" in
    functional)         echo "${CRITIC_TIMEOUT_FUNCTIONAL:-4200}" ;;
    # `console` has to exercise the whole app to provoke errors before it can
    # collect them, so it is as wide as functional in practice — it timed out at
    # 1800s and lost the dimension. `data` recomputes money by hand; `i18n` walks
    # four locales.
    data|i18n|console)  echo "${CRITIC_TIMEOUT_WIDE:-3600}" ;;
    *)                  echo "$TIMEOUT_S" ;;
  esac
}

run_dimension() {
  local dim="$1"
  local scratch="$RUN_DIR/$dim"
  local verdict="$VERDICT_DIR/critic-$dim.json"
  local prompt="$RUN_DIR/prompt-$dim.txt"
  local dim_file="$SCRIPT_DIR/dimensions/$dim.md"
  local dim_timeout_s; dim_timeout_s=$(dim_timeout "$dim")

  mkdir -p "$scratch"

  # Mark coverage HERE, where the dimension really starts — not where the sweep was
  # launched. The orchestrator used to do it, and it cannot know: this script aborts
  # at the boot gate before any dimension exists, so eight dimensions were recorded as
  # covered without running, twice, and stayed retired because coverage only resets on
  # a closing loop.
  mkdir -p "$(dirname "$COVERED_DIMS_FILE")" 2>/dev/null || true
  grep -qxF "$dim" "$COVERED_DIMS_FILE" 2>/dev/null || echo "$dim" >> "$COVERED_DIMS_FILE"

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
  #
  # $REPO_PKG is in scope because several dimensions are explicitly told to read
  # the source: `design` compares the UI against docs/calm-handoff.md, and `i18n`
  # cross-checks on-screen strings against lib/l10n/*.arb to tell a missing
  # translation from a hardcoded literal. Without it those briefs are unfollowable.
  local started ended elapsed rc
  started=$(date +%s)
  AGENT_SLOT="critic-$dim" \
  AGENT_ADD_DIRS="$scratch:$QA_TOOLS:$RUN_DIR:$REPO_PKG" \
  CLAUDE_MODEL="${CRITIC_MODEL:-sonnet}" \
  bash "$SCRIPT_DIR/run-agent.sh" "$prompt" "$QA_TOOLS" "$dim_timeout_s" \
    > "$RUN_DIR/$dim.log" 2>&1
  rc=$?
  ended=$(date +%s); elapsed=$((ended - started))

  # SALVAGE RETRY. A headless agent can finish its turn without writing the
  # verdict — the first real run had a tester end with "I'll wait for the
  # background process to notify me", which in a `-p` session never happens. That
  # threw away ten minutes of real testing.
  #
  # Only retried when the run ended EARLY: an agent killed by the timeout was
  # genuinely still working and re-running it would just burn the same time again.
  if [ ! -f "$verdict" ] && [ "$elapsed" -lt $((dim_timeout_s / 2)) ]; then
    log "  [$dim] sem veredicto após ${elapsed}s (terminou cedo) — a repetir uma vez"
    {
      cat "$prompt"
      echo ""
      echo "---"
      echo ""
      echo "# ATENÇÃO — segunda tentativa"
      echo ""
      echo "A tentativa anterior terminou SEM escrever o veredicto. Foi trabalho"
      echo "perdido. Isto é uma sessão headless: não há notificações nem segundo"
      echo "turno. Corre tudo de forma síncrona e **escreve o veredicto em"
      echo "\`$verdict\` como última acção**, mesmo que só tenhas \`findings: []\`."
    } > "$prompt.retry"
    AGENT_SLOT="critic-$dim" \
    AGENT_ADD_DIRS="$scratch:$QA_TOOLS:$RUN_DIR:$REPO_PKG" \
    CLAUDE_MODEL="${CRITIC_MODEL:-sonnet}" \
    bash "$SCRIPT_DIR/run-agent.sh" "$prompt.retry" "$QA_TOOLS" "$dim_timeout_s" \
      >> "$RUN_DIR/$dim.log" 2>&1
    rc=$?
  fi

  if [ -f "$verdict" ]; then
    local n; n=$(jq '(.findings // []) | length' "$verdict" 2>/dev/null || echo "?")
    log "  [$dim] rc=$rc findings=$n"

    # FILE IMMEDIATELY, per dimension.
    #
    # Filing used to happen once, after every dimension had finished. With seven
    # dimensions at a concurrency of three that meant NOTHING reached the tracker
    # for forty minutes — findings existed but were invisible, and the run looked
    # dead from outside. Worse, a crash before the end lost every finding at once.
    #
    # Per-dimension filing is safe because the filer de-duplicates against the
    # issues actually on GitHub (open and closed) on every invocation, so a later
    # dimension reporting the same defect still collapses onto the first one. The
    # lock only stops two dimensions filing at the same instant, which would let
    # both miss the other's just-created issue.
    # The verdict is deleted ONLY if filing actually succeeded.
    #
    # It used to be removed unconditionally right after the call, which turned any
    # filing failure into permanent data loss. That is exactly what happened: one
    # `dial tcp ... i/o timeout` from the GitHub API crashed the filer, and
    # functional's 4 findings and perf's 1 were deleted seconds later — an hour of
    # testing destroyed by a transient network blip. Keeping the verdict means the
    # next run can file it instead.
    #
    # PIPESTATUS, not $?: the pipe through sed would otherwise mask the exit code.
    local file_rc
    (
      flock 8
      python3 "$SCRIPT_DIR/file-findings.py" \
        --repo "$REPO" --branch "$BRANCH" --run-id "$RUN_ID" --run-dir "$RUN_DIR" \
        "$verdict" 2>&1 | sed "s/^/  [$dim] /"
      exit "${PIPESTATUS[0]}"
    ) 8>"$LOG_DIR/.filing.lock"
    file_rc=$?

    if [ "$file_rc" -eq 0 ]; then
      rm -f "$verdict"
    else
      log "  [$dim] ARQUIVAMENTO FALHOU (rc=$file_rc) — veredicto PRESERVADO em $verdict"
    fi
  else
    log "  [$dim] rc=$rc SEM VEREDICTO (ver $RUN_DIR/$dim.log)"
    if [ "$rc" = "124" ]; then
      log "  [$dim] rc=124 = TIMEOUT (${dim_timeout_s}s). Dimensão perdida — considera subir o timeout."
    fi
  fi
}

# CONCURRENCY DEPENDS ON WHICH ENGINE IS ANSWERING.
#
# The subscription tolerates the full fan-out. The Ollama fallback does not: with
# seven dimensions launched together every one of them printed "Execution error" and
# then sat doing nothing until its 1800s timeout expired. Four dimensions burned two
# hours of wall clock and produced not one verdict.
#
# Not the model and not the invocation — both were checked directly while the sweep
# was failing. A single `ollama launch claude --model deepseek-v4-flash:cloud` with
# the same wrapper answered correctly, rc=0. What it cannot take is seven at once.
#
# So when the subscription is in cooldown the fan-out narrows. Slower, and slower is
# not the problem worth solving here: a sweep that takes longer still finds defects,
# a sweep that returns nothing finds none.
COOLDOWN_FILE="$STATE_DIR/claude-usage-cooldown"
if [ -f "$COOLDOWN_FILE" ] && [ "$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)" -gt "$(date +%s)" ]; then
  FALLBACK_CONCURRENCY="${TEAM_FALLBACK_CONCURRENCY:-2}"
  if [ "$CONCURRENCY" -gt "$FALLBACK_CONCURRENCY" ]; then
    log "subscrição em cooldown — concorrência $CONCURRENCY -> $FALLBACK_CONCURRENCY (o fallback rebenta em paralelo)"
    CONCURRENCY="$FALLBACK_CONCURRENCY"
  fi
fi

# THE FALLBACK CANNOT DRIVE THE TESTERS, SO DO NOT PRETEND IT CAN.
#
# Measured, not assumed. With the subscription in cooldown every dimension printed
# "Execution error" within seconds and then sat idle until its 1800s timeout expired.
# Seven dimensions did that: roughly two hours of wall clock, zero verdicts, and the
# run directory left with empty logs that look identical to a sweep that found nothing.
#
# What it is NOT — each ruled out by direct test against the same wrapper while the
# sweep was failing: not the model (a single request answers, rc=0), not the flags
# (same flags with a short prompt answer fine), not prompt size (200 bytes fail as
# reliably as 10 000), not encoding (both cuts are valid UTF-8, and Portuguese text
# with accents works), not multi-line, not the leading `#`, not dimension concurrency
# (the cap was already 3, and the failures happen one at a time too).
#
# I could not isolate it further: what remains is inside `ollama launch claude`, which
# this project does not own. So the damage gets bounded instead. The write-path roles
# — curator, implementer — demonstrably DO work on the fallback and keep running; it
# is specifically the browser-driving testers that do not.
#
# Skipping is strictly better than timing out: the dimensions stay uncovered, so the
# sweep repeats for real once the subscription returns, instead of being recorded as
# done-with-no-findings.
COOLDOWN_FILE="$STATE_DIR/claude-usage-cooldown"
if [ "${CRITIC_ALLOW_FALLBACK:-0}" != "1" ] \
   && [ -f "$COOLDOWN_FILE" ] \
   && [ "$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)" -gt "$(date +%s)" ]; then
  UNTIL_HHMM=$(date -d "@$(cat "$COOLDOWN_FILE")" +%H:%M 2>/dev/null || echo "?")
  log "subscrição em cooldown até $UNTIL_HHMM — NÃO lanço testers"
  log "  o fallback não consegue conduzir o browser: erra em segundos e fica pendurado"
  log "  até ao timeout. As dimensões ficam por cobrir e este varrimento repete-se."
  exit 0
fi

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
