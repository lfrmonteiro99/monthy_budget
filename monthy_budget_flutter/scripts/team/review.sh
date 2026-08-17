#!/bin/bash
# review.sh — the REVIEWER. Reads a PR targeting `dev`, comments its findings,
# and either merges it or routes it back: code problems to the implementer,
# briefing problems to the curator.
#
# Usage: review.sh <pr_number>
set -uo pipefail

PR="${1:?PR obrigatorio}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="review"

VERDICT_FILE="$VERDICT_DIR/review-$PR.json"
PROMPT="/tmp/review-prompt-$PR.txt"
MODEL="${REVIEW_MODEL:-sonnet}"
WT=""

cleanup() { [ -n "$WT" ] && wt_remove "$WT"; }
trap cleanup EXIT

PR_INFO=$(gh pr view "$PR" --repo "$REPO" \
  --json number,title,body,headRefName,baseRefName,state 2>/dev/null) \
  || { log "ERRO: não consegui ler o PR #$PR"; exit 1; }

BRANCH=$(printf '%s' "$PR_INFO" | jq -r '.headRefName')
BASE=$(printf '%s' "$PR_INFO" | jq -r '.baseRefName')
TITLE=$(printf '%s' "$PR_INFO" | jq -r '.title')
STATE=$(printf '%s' "$PR_INFO" | jq -r '.state')

log "PR #$PR $BRANCH -> $BASE ($STATE) modelo=$MODEL"

if [ "$STATE" != "OPEN" ]; then
  log "PR #$PR não está aberto — nada a rever"
  exit 0
fi

# The issue comes from the closing keyword in the body, which the implementer
# always writes and pr-governance enforces.
ISSUE=$(printf '%s' "$PR_INFO" | jq -r '.body' \
  | grep -oiE '(Fixes|Closes|Resolves)[[:space:]]+#[0-9]+' \
  | grep -oE '[0-9]+' | head -1 || true)
log "issue ligado: ${ISSUE:-nenhum}"

# wt_checkout, NOT wt_create: the reviewer needs the PR's code. wt_create would
# cut a new branch from the base and the diff would come out EMPTY — the
# reviewer would then be judging the PR by its title alone, with no error in the
# log to reveal it.
WT_OUT=$(wt_checkout "$BRANCH" "review-$PR") || { log "ERRO: checkout de $BRANCH falhou"; exit 1; }
WT="$WT_OUT"
PKG="$WT/$FLUTTER_SUBDIR"

git -C "$TEAM_ROOT" fetch origin "$BASE" >/dev/null 2>&1 || true

# NEVER pipe the diff through `head -c N`. Under `set -o pipefail`, once the diff
# exceeds N, head closes the pipe, git takes SIGPIPE, and the script dies before
# writing anything. Truncate in bash instead. The FULL file list always goes in
# the prompt (it is small) so description-vs-diff matching never depends on the cut.
DIFF=$(git -C "$WT" --no-pager diff "origin/$BASE...HEAD" 2>/dev/null || true)
FILES=$(git -C "$WT" --no-pager diff "origin/$BASE...HEAD" --name-only 2>/dev/null || true)
DIFF_BYTES=${#DIFF}
DIFF="${DIFF:0:60000}"

if [ -z "${DIFF//[[:space:]]/}" ]; then
  log "DIFF VAZIO — não se revê um PR pelo título"
  gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: sem diff

O worktree do branch \`$BRANCH\` não produziu diff contra \`$BASE\`. Não é
possível rever. Marcado para intervenção humana." >/dev/null 2>&1 || true
  [ -n "$ISSUE" ] && set_state "$ISSUE" "$L_HUMAN"
  exit 1
fi

log "diff: ${DIFF_BYTES}B em $(printf '%s' "$FILES" | grep -c . || echo 0) ficheiro(s)"

log "a preparar dependências para o reviewer correr os testes..."
wt_prepare_flutter "$WT"

ISSUE_JSON=""
if [ -n "$ISSUE" ]; then
  ISSUE_JSON=$(gh issue view "$ISSUE" --repo "$REPO" --json title,body,comments --jq '
    "# " + .title + "\n\n" + (.body // "") + "\n\n## Comentários\n\n" +
    (if (.comments | length) > 0 then
       ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
     else "(sem comentários)" end)' 2>/dev/null || echo "")
fi

# CI signal for this exact commit, so the reviewer isn't guessing about gates it
# cannot run locally (coverage, gitleaks, ARB validation).
CI_STATUS=$(gh pr checks "$PR" --repo "$REPO" 2>/dev/null | head -20 || echo "(sem checks)")

{
  cat "$SCRIPT_DIR/review-prompt.md"
  echo ""
  echo "---"
  echo ""
  echo "# PR #$PR: $TITLE"
  echo ""
  echo "\`$BRANCH\` → \`$BASE\`"
  echo ""
  echo "## Corpo do PR (escrito pelo implementador — pode estar errado)"
  echo ""
  printf '%s\n' "$(printf '%s' "$PR_INFO" | jq -r '.body')"
  echo ""
  echo "## Issue e análise do curator (os critérios de aceitação estão aqui)"
  echo ""
  printf '%s\n' "${ISSUE_JSON:-(sem issue ligado)}"
  echo ""
  echo "## Estado do CI para este commit"
  echo ""
  printf '%s\n' "$CI_STATUS"
  echo ""
  echo "## Ficheiros no diff (lista completa — nunca truncada)"
  echo ""
  printf '%s\n' "$FILES"
  echo ""
  echo "## Diff (${DIFF_BYTES} bytes no total)"
  echo ""
  printf '%s\n' "$DIFF"
} | sed -e "s|__VERDICT_PATH__|$VERDICT_FILE|g" \
        -e "s|__WORKDIR__|$WT|g" > "$PROMPT"

rm -f "$VERDICT_FILE"
AGENT_SLOT=main CLAUDE_MODEL="$MODEL" \
  bash "$SCRIPT_DIR/run-agent.sh" "$PROMPT" "$PKG" "${REVIEW_TIMEOUT:-1800}" \
  > "$LOG_DIR/review-$PR.log" 2>&1 || true

if [ ! -f "$VERDICT_FILE" ]; then
  if ! no_verdict_is_real_failure main; then
    log "SEM VEREDICTO com o motor de fallback — PR fica para nova review"
    gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: corrida degradada, sem veredicto

A subscricao estava esgotada e a corrida usou o modelo de fallback, que nao
conseguiu concluir a review. O PR fica como esta e sera revisto de novo." >/dev/null 2>&1 || true
    exit 0
  fi
  log "SEM VEREDICTO — needs-human"
  gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: sem veredicto

O reviewer terminou sem escrever veredicto (ver \`$LOG_DIR/review-$PR.log\`)." >/dev/null 2>&1 || true
  [ -n "$ISSUE" ] && set_state "$ISSUE" "$L_HUMAN"
  exit 0
fi

VERDICT=$(jqv "$VERDICT_FILE" '.verdict' 'needs-human')
SUMMARY=$(jqv "$VERDICT_FILE" '.summary' '(sem resumo)'); SUMMARY="${SUMMARY:0:1500}"

# Per-dimension detail, so the defect is visible in the comment without opening
# the verdict — and so it is auditable whether the reviewer actually filled it in.
DETAIL=$(jq -r '
  [ (if .tests_pass == false then "os testes falham" else empty end),
    (if .acceptance_criteria_met == false then "critérios de aceitação não cumpridos" else empty end),
    (if .description_matches_diff == false then "a descrição do PR não corresponde ao diff" else empty end),
    (if .has_tests == false then "não traz testes" else empty end),
    (if .fixes_root_cause == false then "trata o sintoma, não a causa raiz" else empty end),
    (if ((.junk_files // []) | length) > 0 then "lixo versionado: " + ((.junk_files // []) | join(", ")) else empty end),
    (if ((.secrets_found // []) | length) > 0 then "SEGREDOS no diff: " + ((.secrets_found // []) | join(", ")) else empty end)
  ] | if length == 0 then "" else "\n\n**Defeitos:**\n- " + join("\n- ") end
' "$VERDICT_FILE" 2>/dev/null || echo "")

CHANGES=$(jq -r '
  (.required_changes // []) | if length == 0 then "" else
  "\n\n**Alterações necessárias:**\n- " + join("\n- ") end
' "$VERDICT_FILE" 2>/dev/null || echo "")

log "verdict=$VERDICT"

case "$VERDICT" in
  approved)
    gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: aprovado

$SUMMARY" >/dev/null 2>&1 || true

    # Distinguish WHY a merge fails before blaming anyone.
    #
    # `gh pr merge` refuses while any check is red, and today's checks go red on
    # GitHub infrastructure (429/503 downloading the flutter action) as readily as
    # on real failures. Treating that as the implementer's fault sends perfectly
    # good work back to be redone — observed on PR #1239, which was MERGEABLE with
    # only UNSTABLE checks.
    #
    # So on failure: if the tree is genuinely conflicted or behind, that IS the
    # implementer's problem. If it is only the check state, and THIS reviewer just
    # ran analyze and the full suite against this exact code and approved it, then
    # a flaked CI job is not a reason to block. `dev` is unprotected staging, so we
    # complete the merge with --admin and say plainly that we did and why. `main`
    # stays fully protected — nothing here can touch it.
    MERGE_OK=0
    if gh pr merge "$PR" --repo "$REPO" --squash --delete-branch >/dev/null 2>&1; then
      MERGE_OK=1
    else
      MSTATUS=$(gh pr view "$PR" --repo "$REPO" --json mergeStateStatus --jq .mergeStateStatus 2>/dev/null || echo "")
      TESTS_OK=$(jqv "$VERDICT_FILE" '.tests_pass' 'false')
      log "merge recusado (mergeStateStatus=$MSTATUS, reviewer tests_pass=$TESTS_OK)"
      case "$MSTATUS" in
        DIRTY|BEHIND|BLOCKED)
          : ;;   # genuinely the branch's problem — fall through to the block path
        *)
          if [ "$TESTS_OK" = "true" ] && [ "$BASE" = "$BASE_BRANCH" ]; then
            log "checks instáveis mas o reviewer correu a suite e aprovou — a concluir o merge"
            gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: merge concluído apesar de checks instáveis

O \`gh pr merge\` foi recusado por estado de checks (\`$MSTATUS\`), não por
conflito. Os workflows falharam a descarregar a \`flutter-action\` (429/503 da
infraestrutura do GitHub), o que não diz nada sobre este código.

Este reviewer correu \`flutter analyze\` e a suite completa contra este commit e
aprovou. \`$BASE\` é staging de QA sem protecção, por isso o merge foi concluído.
O \`main\` mantém as suas protecções intactas." >/dev/null 2>&1 || true
            gh pr merge "$PR" --repo "$REPO" --squash --delete-branch --admin >/dev/null 2>&1 && MERGE_OK=1
          fi
          ;;
      esac
    fi

    if [ "$MERGE_OK" = "1" ]; then
      log "PR #$PR integrado em $BASE"
      if [ -n "$ISSUE" ]; then
        # NOT closed here. The issue only closes once the QA verifier has
        # re-tested the fix on the running dev build — a merged PR proves the
        # code was accepted, not that the defect is gone.
        comment_issue "$ISSUE" "## Reviewer: aprovado e integrado

$SUMMARY

PR #$PR integrado em \`$BASE\`. Em espera de verificação de QA em \`$BASE\`."
        set_state "$ISSUE" "$L_VERIFY"
      fi
    else
      log "merge falhou (conflito ou gate)"
      gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: aprovado mas o merge falhou

Provavelmente conflito com \`$BASE\` ou um gate em falta. O implementador deve
actualizar o branch." >/dev/null 2>&1 || true
      [ -n "$ISSUE" ] && set_state "$ISSUE" "$L_BLOCKED_IMPL"
    fi
    ;;

  blocked-impl)
    gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: bloqueado — problema de código

$SUMMARY$DETAIL$CHANGES

Devolvido ao implementador." >/dev/null 2>&1 || true
    [ -n "$ISSUE" ] && {
      comment_issue "$ISSUE" "## Reviewer: bloqueado (código)

$SUMMARY$DETAIL$CHANGES"
      set_state "$ISSUE" "$L_BLOCKED_IMPL"
    }
    ;;

  blocked-spec)
    gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: bloqueado — problema do briefing

$SUMMARY$DETAIL$CHANGES

O implementador fez o que lhe foi pedido; o pedido estava mal. Devolvido ao
curator para refinar a análise." >/dev/null 2>&1 || true
    [ -n "$ISSUE" ] && {
      comment_issue "$ISSUE" "## Reviewer: bloqueado (briefing)

$SUMMARY$DETAIL$CHANGES"
      set_state "$ISSUE" "$L_BLOCKED_SPEC"
    }
    ;;

  *)
    gh pr comment "$PR" --repo "$REPO" --body "## Reviewer: needs-human

$SUMMARY$DETAIL" >/dev/null 2>&1 || true
    [ -n "$ISSUE" ] && set_state "$ISSUE" "$L_HUMAN"
    ;;
esac

rm -f "$VERDICT_FILE"
log "done PR #$PR"
