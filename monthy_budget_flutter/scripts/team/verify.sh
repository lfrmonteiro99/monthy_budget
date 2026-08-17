#!/bin/bash
# verify.sh — the QA VERIFIER. Re-tests a merged fix against the running `dev`
# build and closes the issue only if the defect is genuinely gone.
#
# This is the step that makes the whole pipeline honest. A merged PR proves the
# reviewer liked the code; it proves nothing about the app. Only driving the real
# UI does.
#
# On failure it routes by cause, exactly like the reviewer:
#   fail-impl -> implementer (the fix does not work)
#   fail-spec -> curator     (the acceptance criteria were wrong)
#
# Usage: verify.sh <issue_number> [--no-serve]
set -uo pipefail

ISSUE="${1:?issue obrigatorio}"; shift || true
DO_SERVE=1
for a in "$@"; do [ "$a" = "--no-serve" ] && DO_SERVE=0; done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="verify"

BRANCH="$BASE_BRANCH"
APP_PORT="$PORT_DEV"
APP_URL="http://127.0.0.1:$APP_PORT"
VERDICT_FILE="$VERDICT_DIR/verify-$ISSUE.json"
PROMPT="/tmp/verify-prompt-$ISSUE.txt"
SCRATCH="$LOG_DIR/verify-$ISSUE-$(date +%H%M%S)"
QA_TOOLS="${TEAM_QA_TOOLS:-$HOME/Documentos/monthy-budget-qa-tools}"
MODEL="${VERIFY_MODEL:-sonnet}"

mkdir -p "$SCRATCH"
log "issue #$ISSUE branch=$BRANCH modelo=$MODEL"

# ── The app WITH the fix ───────────────────────────────────────────────────
# Rebuilt from dev's current head, so the fix that was just merged is actually
# in the bundle being tested. Without this the verifier would re-test the old
# build and pass or fail for the wrong reason.
if [ "$DO_SERVE" = "1" ]; then
  log "a garantir que a app de '$BRANCH' está a servir e actualizada..."
  if ! bash "$SCRIPT_DIR/serve-app.sh" "$BRANCH" --port "$APP_PORT"; then
    log "ERRO: não consegui servir '$BRANCH'"
    comment_issue "$ISSUE" "## QA: verificação inconclusiva

Não foi possível compilar/servir a app a partir de \`$BRANCH\`, portanto o fix
não pôde ser verificado. O issue fica em \`$L_HUMAN\`."
    set_state "$ISSUE" "$L_HUMAN"
    exit 1
  fi
fi

if ! curl -fsS -o /dev/null --max-time 5 "$APP_URL/"; then
  log "ERRO: $APP_URL não responde"
  set_state "$ISSUE" "$L_HUMAN"
  exit 1
fi

if ! bash "$SCRIPT_DIR/qa-tools-setup.sh" >>"$LOG_DIR/verify-$ISSUE.toolkit.log" 2>&1; then
  log "ERRO: toolkit de browser não ficou pronto"
  set_state "$ISSUE" "$L_HUMAN"
  exit 1
fi

ISSUE_JSON=$(gh issue view "$ISSUE" --repo "$REPO" \
  --json title,body,comments --jq '
  "# " + .title + "\n\n" + (.body // "") + "\n\n## Comentários\n\n" +
  (if (.comments | length) > 0 then
     ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
   else "(sem comentários)" end)' 2>/dev/null) \
  || { log "ERRO: não consegui ler o issue"; exit 1; }

{
  cat "$SCRIPT_DIR/verify-prompt.md"
  echo ""
  echo "---"
  echo ""
  echo "# O issue a verificar"
  echo ""
  echo "Os \"Critérios de aceitação\" e o \"Como testar\" estão nos comentários do"
  echo "curator abaixo. O relato do implementador diz o que ele afirma ter feito —"
  echo "confirma na app, não acredites."
  echo ""
  printf '%s\n' "$ISSUE_JSON"
} | sed -e "s|__VERDICT_PATH__|$VERDICT_FILE|g" \
        -e "s|__APP_URL__|$APP_URL|g" \
        -e "s|__BRANCH__|$BRANCH|g" \
        -e "s|__SCRATCH__|$SCRATCH|g" \
        -e "s|__QA_TOOLS__|$QA_TOOLS|g" > "$PROMPT"

rm -f "$VERDICT_FILE"
AGENT_SLOT=main CLAUDE_MODEL="$MODEL" \
  AGENT_ADD_DIRS="$SCRATCH:$QA_TOOLS" \
  bash "$SCRIPT_DIR/run-agent.sh" "$PROMPT" "$QA_TOOLS" "${VERIFY_TIMEOUT:-1800}" \
  > "$LOG_DIR/verify-$ISSUE.log" 2>&1; AGENT_RC=$?

if [ ! -f "$VERDICT_FILE" ]; then
  if ! no_verdict_is_real_failure main "$AGENT_RC"; then
    log "SEM VEREDICTO (corrida degradada ou não arrancada) — issue fica em $L_VERIFY"
    comment_issue "$ISSUE" "## QA: corrida degradada, sem veredicto

A corrida nao produziu veredicto por uma razao alheia ao issue: ou a subscricao
estava esgotada e o modelo de fallback nao
conseguiu concluir a verificacao. Fica em \`$L_VERIFY\` para nova tentativa."
    exit 0
  fi
  log "SEM VEREDICTO — needs-human"
  comment_issue "$ISSUE" "## QA: sem veredicto

O verificador terminou sem escrever veredicto (ver \`$LOG_DIR/verify-$ISSUE.log\`)."
  set_state "$ISSUE" "$L_HUMAN"
  exit 0
fi

VERDICT=$(jqv "$VERDICT_FILE" '.verdict' 'inconclusive')
SUMMARY=$(jqv "$VERDICT_FILE" '.summary' '(sem resumo)'); SUMMARY="${SUMMARY:0:1500}"

CRITERIA=$(jq -r '
  (.criteria // []) | if length == 0 then "" else
  "\n\n**Critérios:**\n" + ([.[] |
    "- " + (if .met then "✅" else "❌" end) + " " + (.criterion // "?") +
    (if (.evidence // "") != "" then " — " + .evidence else "" end)] | join("\n"))
  end' "$VERDICT_FILE" 2>/dev/null || echo "")

REGRESSIONS=$(jq -r '
  (.regressions // []) | if length == 0 then "" else
  "\n\n**Regressões encontradas:**\n- " + join("\n- ") end' "$VERDICT_FILE" 2>/dev/null || echo "")

SYMPTOM=$(jqv "$VERDICT_FILE" '.original_symptom_gone' '')

log "verdict=$VERDICT symptom_gone=${SYMPTOM:-n/d}"

case "$VERDICT" in
  pass)
    comment_issue "$ISSUE" "## QA: verificado ✅

$SUMMARY$CRITERIA$REGRESSIONS

Verificado na app a correr a partir de \`$BRANCH\`. A fechar."
    set_state "$ISSUE" "$L_DONE"
    gh issue close "$ISSUE" --repo "$REPO" --reason completed >/dev/null 2>&1 || true
    log "#$ISSUE fechado — verificado"
    ;;

  fail-impl)
    comment_issue "$ISSUE" "## QA: reprovado ❌ — a correção não resolve

$SUMMARY$CRITERIA$REGRESSIONS

Devolvido ao implementador. O código já está em \`$BRANCH\`, portanto a próxima
correção parte de lá."
    set_state "$ISSUE" "$L_BLOCKED_IMPL"
    log "#$ISSUE -> $L_BLOCKED_IMPL"
    ;;

  fail-spec)
    comment_issue "$ISSUE" "## QA: reprovado ❌ — o briefing estava errado

$SUMMARY$CRITERIA$REGRESSIONS

A implementação cumpriu os critérios e o defeito persiste: os critérios não
atacavam a causa. Devolvido ao curator para reanalisar."
    set_state "$ISSUE" "$L_BLOCKED_SPEC"
    log "#$ISSUE -> $L_BLOCKED_SPEC"
    ;;

  *)
    comment_issue "$ISSUE" "## QA: inconclusivo

$SUMMARY$CRITERIA

Não foi possível verificar na app."
    set_state "$ISSUE" "$L_HUMAN"
    log "#$ISSUE -> $L_HUMAN (inconclusivo)"
    ;;
esac

rm -f "$VERDICT_FILE"
log "done #$ISSUE"
