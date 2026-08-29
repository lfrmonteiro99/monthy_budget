#!/bin/bash
# verify.sh — the QA VERIFIER. Re-tests an ALREADY INTEGRATED fix against the
# running `dev` build and closes the issue only if the defect is genuinely gone.
#
# The pre-merge gate (premerge.sh) has already proven the fix works on its own
# branch, so this stage answers the question that one cannot: does it still work
# now that it sits in `dev` alongside every other fix that landed since? That is
# why both exist and why neither replaces the other.
#
# On failure it routes by cause, exactly like the reviewer:
#   fail-impl -> implementer (the fix does not work)
#   fail-spec -> curator     (the acceptance criteria were wrong)
#
# Usage: verify.sh <issue_number>
set -uo pipefail

ISSUE="${1:?issue obrigatorio}"; shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="verify"

BRANCH="$BASE_BRANCH"
APP_PORT="$PORT_DEV"
VERDICT_FILE="$VERDICT_DIR/verify-$ISSUE.json"
MODEL="${VERIFY_MODEL:-sonnet}"
export UI_TESTER_MODEL="$MODEL"
export UI_TESTER_TIMEOUT="${VERIFY_TIMEOUT:-1800}"

log "issue #$ISSUE branch=$BRANCH modelo=$MODEL"

# ── The app WITH the fix ───────────────────────────────────────────────────
# Built from dev's current head, so the fix that was just merged is actually in
# the bundle being tested. Without this the verifier would re-test the old build
# and pass or fail for the wrong reason.
#
# The tester itself lives in lib.sh and is shared with the pre-merge gate — see
# run_ui_tester for why there is only one copy of it.
STAGE_CONTEXT="És o **tester de QA que fecha o ciclo**. Um defeito foi reportado, analisado,
corrigido, aprovado no gate pré-merge e **já integrado em \`dev\`**. O teu trabalho
é provar que continua resolvido depois de integrado, ao lado dos outros fixes que
entraram — ou provar que a integração o partiu."

run_ui_tester "$ISSUE" "$BRANCH" "$APP_PORT" "$VERDICT_FILE" verify "$STAGE_CONTEXT"
TESTER_RC=$?

case "$TESTER_RC" in
  1)
    log "ERRO: ambiente falhou — fica em $L_VERIFY para nova tentativa"
    comment_issue "$ISSUE" "## QA: não consegui testar a app

Não foi possível compilar, servir ou instrumentar \`$BRANCH\`. Isto é do ambiente,
não do fix — o issue fica em \`$L_VERIFY\` e será verificado na próxima passagem."
    exit 1
    ;;
  2)
    log "SEM VEREDICTO (corrida degradada ou não arrancada) — issue fica em $L_VERIFY"
    comment_issue "$ISSUE" "## QA: corrida degradada, sem veredicto

A corrida não produziu veredicto por uma razão alheia ao issue: a subscrição
estava esgotada e o modelo de fallback não conseguiu concluir a verificação.
Fica em \`$L_VERIFY\` para nova tentativa."
    exit 0
    ;;
  3)
    # No verdict on a healthy run. Requeueing to the same state is right until
    # the run has burned the whole clock twice — see note_verdictless_run.
    if N=$(note_verdictless_run "$ISSUE" "$UI_TESTER_LAST_RC"); then
      log "SEM VEREDICTO — fica em $L_VERIFY para nova tentativa"
      comment_issue "$ISSUE" "## QA: corrida sem veredicto

A corrida terminou sem escrever veredicto (ver \`$UI_TESTER_LOG\`).
Falha da corrida, não do fix — fica na fila para ser verificado de novo."
    else
      log "SEM VEREDICTO pela ${MAX_TIMEOUTS}.ª vez por timeout — a devolver ao curator"
      comment_issue "$ISSUE" "$(verdictless_escalation_body "verificador de QA" "$MAX_TIMEOUTS" "${VERIFY_TIMEOUT:-1800}")"
      set_state "$ISSUE" "$L_BLOCKED_SPEC"
    fi
    exit 0
    ;;
esac

clear_verdictless_runs "$ISSUE"

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
    # No "inconclusive" destination exists any more. An unusable verdict means the
    # fix is not demonstrated, which is the implementer's to answer.
    comment_issue "$ISSUE" "## QA: resultado não reconhecido (\`$VERDICT\`)

$SUMMARY$CRITERIA

O veredicto não usou um dos resultados válidos. Como o fix não ficou demonstrado,
volta ao implementador."
    set_state "$ISSUE" "$L_BLOCKED_IMPL"
    log "#$ISSUE -> $L_BLOCKED_IMPL (veredicto inválido)"
    ;;
esac

rm -f "$VERDICT_FILE"
log "done #$ISSUE"
