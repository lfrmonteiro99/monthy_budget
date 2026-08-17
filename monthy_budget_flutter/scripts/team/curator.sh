#!/bin/bash
# curator.sh — the CURATOR. Takes a raw critic issue, finds the root cause in the
# code, and writes the briefing the implementer works from: root cause, fix
# approach, acceptance criteria and test steps. Closes issues that turn out to be
# non-defects or already fixed.
#
# Never touches production code — only the issue.
#
# Usage: curator.sh <issue_number>
set -uo pipefail

ISSUE="${1:?issue obrigatorio}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="curator"

VERDICT_FILE="$VERDICT_DIR/curator-$ISSUE.json"
WT=""
PROMPT="/tmp/curator-prompt-$ISSUE.txt"
MODEL="${CURATOR_MODEL:-sonnet}"

cleanup() { [ -n "$WT" ] && wt_remove "$WT"; }
trap cleanup EXIT

log "issue #$ISSUE modelo=$MODEL"

# A read-only checkout of dev: the curator reasons about the code that fixes will
# be applied to, not about production. Detached, so nothing can be pushed.
WT_OUT=$(wt_checkout "$BASE_BRANCH" "curator-$ISSUE") || { log "ERRO: checkout de $BASE_BRANCH falhou"; exit 1; }
WT="$WT_OUT"
REPO_PKG="$WT/$FLUTTER_SUBDIR"

ISSUE_JSON=$(gh issue view "$ISSUE" --repo "$REPO" \
  --json title,body,labels,comments --jq '
  "# " + .title + "\n\n" +
  "## Corpo\n\n" + (.body // "(vazio)") + "\n\n" +
  "## Labels\n\n" + ([.labels[].name] | join(", ")) + "\n\n" +
  "## Comentários\n\n" +
  (if (.comments | length) > 0 then
     ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
   else "(sem comentários)" end)
' 2>/dev/null) || { log "ERRO: não consegui ler o issue #$ISSUE"; exit 1; }

{
  cat "$SCRIPT_DIR/curator-prompt.md"
  echo ""
  echo "---"
  echo ""
  echo "# O issue a curar"
  echo ""
  printf '%s\n' "$ISSUE_JSON"
} | sed -e "s|__VERDICT_PATH__|$VERDICT_FILE|g" \
        -e "s|__REPO_PKG__|$REPO_PKG|g" > "$PROMPT"

# STALE: delete before the run, so a verdict inherited from a previous run can
# never be read as this run's result.
rm -f "$VERDICT_FILE"
AGENT_SLOT=main CLAUDE_MODEL="$MODEL" \
  bash "$SCRIPT_DIR/run-agent.sh" "$PROMPT" "$REPO_PKG" "${CURATOR_TIMEOUT:-900}" \
  > "$LOG_DIR/curator-$ISSUE.log" 2>&1; AGENT_RC=$?

if [ ! -f "$VERDICT_FILE" ]; then
  if ! no_verdict_is_real_failure main "$AGENT_RC"; then
    log "SEM VEREDICTO (corrida degradada ou não arrancada) — issue fica em $L_TRIAGE para nova tentativa"
    comment_issue "$ISSUE" "## Curator: corrida degradada, sem veredicto

A corrida não produziu veredicto por uma razão alheia ao issue: ou a subscrição
estava esgotada e o modelo de fallback não
conseguiu concluir a análise. **Isto não é um problema do issue** — fica na fila
para ser reanalisado quando a subscrição voltar."
    exit 0
  fi
  log "SEM VEREDICTO — needs-human"
  set_state "$ISSUE" "$L_HUMAN"
  comment_issue "$ISSUE" "## Curator: sem veredicto

O curator terminou sem escrever veredicto (ver \`$LOG_DIR/curator-$ISSUE.log\`).
Marcado como \`$L_HUMAN\`."
  exit 0
fi

OUTCOME=$(jqv "$VERDICT_FILE" '.outcome' 'needs-human')
SUMMARY=$(jqv "$VERDICT_FILE" '.summary' '(sem resumo)'); SUMMARY="${SUMMARY:0:600}"
ANALYSIS=$(jqv "$VERDICT_FILE" '.analysis' '')
SEVERITY=$(jqv "$VERDICT_FILE" '.severity' '')

log "outcome=$OUTCOME severity=${SEVERITY:-n/d}"

# Re-grade severity when the curator disagrees with the tester.
case "$SEVERITY" in
  blocker|major|minor)
    gh issue edit "$ISSUE" --repo "$REPO" --add-label "sev:$SEVERITY" \
      --remove-label "$(printf 'sev:blocker,sev:major,sev:minor' | tr ',' '\n' | grep -vx "sev:$SEVERITY" | paste -sd, -)" \
      >/dev/null 2>&1 || true
    ;;
esac

case "$OUTCOME" in
  ready)
    if [ -z "${ANALYSIS//[[:space:]]/}" ]; then
      # A "ready" with no briefing is the failure mode this role exists to
      # prevent: the implementer would get the raw symptom and guess.
      log "outcome=ready mas analysis vazio — needs-human"
      set_state "$ISSUE" "$L_HUMAN"
      comment_issue "$ISSUE" "## Curator: análise vazia

O curator declarou \`ready\` sem escrever a análise. Sem causa raiz nem
critérios de aceitação o implementador não tem por onde pegar."
      exit 0
    fi
    comment_issue "$ISSUE" "## Curator: analisado — pronto a implementar

**Causa raiz (resumo):** $SUMMARY

$ANALYSIS"
    set_state "$ISSUE" "$L_READY"
    log "#$ISSUE -> $L_READY"
    ;;

  not-a-defect)
    comment_issue "$ISSUE" "## Curator: não é defeito

$SUMMARY

$ANALYSIS"
    gh issue close "$ISSUE" --repo "$REPO" --reason "not planned" >/dev/null 2>&1 || true
    set_state "$ISSUE" "$L_DONE"
    log "#$ISSUE fechado (not-a-defect)"
    ;;

  already-fixed)
    comment_issue "$ISSUE" "## Curator: já corrigido

$SUMMARY

$ANALYSIS"
    gh issue close "$ISSUE" --repo "$REPO" --reason completed >/dev/null 2>&1 || true
    set_state "$ISSUE" "$L_DONE"
    log "#$ISSUE fechado (already-fixed)"
    ;;

  split)
    COUNT=$(jq '(.subissues // []) | length' "$VERDICT_FILE" 2>/dev/null || echo 0)
    if [ "$COUNT" -lt 2 ]; then
      log "split com $COUNT sub-issues — insuficiente, needs-human"
      set_state "$ISSUE" "$L_HUMAN"
      comment_issue "$ISSUE" "## Curator: split inválido

Pediu \`split\` mas indicou $COUNT sub-issues. Um split precisa de pelo menos 2."
      exit 0
    fi
    CREATED=""
    for i in $(seq 0 $((COUNT - 1))); do
      ST=$(jq -r ".subissues[$i].title // \"\"" "$VERDICT_FILE")
      SB=$(jq -r ".subissues[$i].body // \"\"" "$VERDICT_FILE")
      [ -z "${ST//[[:space:]]/}" ] && continue
      BODY=$(printf 'Parte de #%s\n\n%s\n' "$ISSUE" "$SB")
      URL=$(gh issue create --repo "$REPO" --title "$ST" --body "$BODY" \
              --label "critic,$L_TRIAGE" 2>/dev/null || echo "")
      [ -n "$URL" ] && CREATED="$CREATED
- $URL"
      log "  sub-issue: ${URL:-FALHOU}"
    done
    comment_issue "$ISSUE" "## Curator: partido em sub-issues

$SUMMARY
$CREATED

Este issue fica como agregador; o trabalho acontece nos sub-issues."
    set_state "$ISSUE" "$L_HUMAN"
    ;;

  *)
    comment_issue "$ISSUE" "## Curator: needs-human

$SUMMARY

$ANALYSIS"
    set_state "$ISSUE" "$L_HUMAN"
    log "#$ISSUE -> $L_HUMAN"
    ;;
esac

rm -f "$VERDICT_FILE"
log "done #$ISSUE"
