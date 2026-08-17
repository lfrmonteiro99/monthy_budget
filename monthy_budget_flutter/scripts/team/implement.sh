#!/bin/bash
# implement.sh — the IMPLEMENTER. Takes a curated issue, implements the fix on a
# branch cut from `dev`, and opens a PR into `dev` describing what it did.
#
# Branches are named `qa/issue-N`. That prefix is deliberate: agent-delivery.yml
# ignores `qa/**`, so pushing here cannot auto-merge anything into main behind
# the reviewer's back.
#
# Usage: implement.sh <issue_number>
set -uo pipefail

ISSUE="${1:?issue obrigatorio}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="implement"

BRANCH="qa/issue-$ISSUE"
VERDICT_FILE="$VERDICT_DIR/implement-$ISSUE.json"
PROMPT="/tmp/implement-prompt-$ISSUE.txt"
MODEL="${IMPLEMENT_MODEL:-sonnet}"
WT=""

log "issue #$ISSUE branch=$BRANCH modelo=$MODEL"

set_state "$ISSUE" "$L_WIP"

# Fresh worktree on a branch cut from dev. If the branch already exists (this is
# rework after a block) wt_create falls back to checking it out.
wt_remove "$WT_ROOT/implement-$ISSUE"
WT_OUT=$(wt_create "$BRANCH" "implement-$ISSUE" "$BASE_BRANCH") || {
  log "ERRO: não criei worktree"
  set_state "$ISSUE" "$L_HUMAN"
  comment_issue "$ISSUE" "## Implementador: falhou a preparar o worktree

Não foi possível criar o branch \`$BRANCH\` a partir de \`$BASE_BRANCH\`."
  exit 1
}
WT="$WT_OUT"
PKG="$WT/$FLUTTER_SUBDIR"

# On rework the branch may be behind dev; other fixes have landed since.
git -C "$WT" merge --no-edit "origin/$BASE_BRANCH" >/dev/null 2>&1 || true

log "a preparar dependências..."
wt_prepare_flutter "$WT"

ISSUE_JSON=$(gh issue view "$ISSUE" --repo "$REPO" \
  --json title,body,labels,comments --jq '
  "# " + .title + "\n\n" +
  "## Corpo\n\n" + (.body // "(vazio)") + "\n\n" +
  "## Labels\n\n" + ([.labels[].name] | join(", ")) + "\n\n" +
  "## Comentários (inclui a análise do curator)\n\n" +
  (if (.comments | length) > 0 then
     ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
   else "(sem comentários)" end)
' 2>/dev/null) || { log "ERRO: não consegui ler o issue"; exit 1; }

# Rework: pull the reviewer's and verifier's objections into the prompt.
PR_FEEDBACK=""
EXISTING_PR=$(gh pr list --repo "$REPO" --head "$BRANCH" --state open \
  --json number --jq '.[0].number // empty' 2>/dev/null || echo "")
if [ -n "$EXISTING_PR" ]; then
  PR_FEEDBACK=$(gh pr view "$EXISTING_PR" --repo "$REPO" --json comments --jq '
    (if (.comments | length) > 0 then
       ([.comments[] | "- **@" + (.author.login // "anon") + "**: " + (.body // "")] | join("\n\n"))
     else "(sem comentários)" end)' 2>/dev/null || echo "")
fi

{
  cat "$SCRIPT_DIR/implement-prompt.md"
  echo ""
  echo "---"
  echo ""
  echo "# O issue a implementar"
  echo ""
  printf '%s\n' "$ISSUE_JSON"
  if [ -n "${PR_FEEDBACK//[[:space:]]/}" ]; then
    echo ""
    echo "---"
    echo ""
    echo "# RETRABALHO — feedback no PR #$EXISTING_PR"
    echo ""
    printf '%s\n' "$PR_FEEDBACK"
    echo ""
    echo "Corrige o que foi apontado acima. Não repitas a correção que foi bloqueada."
  fi
} | sed -e "s|__VERDICT_PATH__|$VERDICT_FILE|g" \
        -e "s|__WORKDIR__|$WT|g" \
        -e "s|__BRANCH__|$BRANCH|g" \
        -e "s|__BASE_BRANCH__|$BASE_BRANCH|g" > "$PROMPT"

rm -f "$VERDICT_FILE"
AGENT_SLOT=main CLAUDE_MODEL="$MODEL" \
  bash "$SCRIPT_DIR/run-agent.sh" "$PROMPT" "$PKG" "${IMPLEMENT_TIMEOUT:-2700}" \
  > "$LOG_DIR/implement-$ISSUE.log" 2>&1; AGENT_RC=$?

if [ ! -f "$VERDICT_FILE" ]; then
  if ! no_verdict_is_real_failure main "$AGENT_RC"; then
    log "SEM VEREDICTO (corrida degradada ou não arrancada) — issue volta a $L_READY"
    comment_issue "$ISSUE" "## Implementador: corrida degradada, sem veredicto

A corrida não produziu veredicto por uma razão alheia ao issue: ou a subscrição
estava esgotada e o modelo de fallback não
conseguiu concluir a implementação. **Isto não é um problema do issue** — volta a
\`$L_READY\` para nova tentativa quando a subscrição voltar."
    set_state "$ISSUE" "$L_READY"
    wt_remove "$WT"
    exit 0
  fi
  log "SEM VEREDICTO — needs-human"
  set_state "$ISSUE" "$L_HUMAN"
  comment_issue "$ISSUE" "## Implementador: sem veredicto

Terminou sem escrever veredicto (ver \`$LOG_DIR/implement-$ISSUE.log\`)."
  wt_remove "$WT"
  exit 0
fi

OUTCOME=$(jqv "$VERDICT_FILE" '.outcome' 'needs-human')
SUMMARY=$(jqv "$VERDICT_FILE" '.summary' 'correção automática'); SUMMARY="${SUMMARY:0:200}"
DESCRIPTION=$(jqv "$VERDICT_FILE" '.description' '')
TESTS=$(jqv "$VERDICT_FILE" '.tests' '(não reportado)'); TESTS="${TESTS:0:400}"

# Ignore the worktree's own build artefacts when deciding "did anything change".
CHANGED=$(git -C "$WT" status --porcelain -- "$FLUTTER_SUBDIR" 2>/dev/null | grep -v '/build/' | head -1 || true)

log "outcome=$OUTCOME alterações=${CHANGED:+sim}${CHANGED:-nao}"

if [ "$OUTCOME" != "implemented" ] || [ -z "$CHANGED" ]; then
  REASON="$OUTCOME"
  [ -n "$OUTCOME" ] && [ -z "$CHANGED" ] && REASON="$OUTCOME (sem alterações reais no código)"
  # "blocked" means the briefing was not actionable -> back to the curator.
  # Anything else needs a human.
  if [ "$OUTCOME" = "blocked" ]; then
    set_state "$ISSUE" "$L_BLOCKED_SPEC"
    comment_issue "$ISSUE" "## Implementador: bloqueado — devolvido ao curator

$SUMMARY

$DESCRIPTION

O briefing não era executável como está. O curator deve refiná-lo."
  else
    set_state "$ISSUE" "$L_HUMAN"
    comment_issue "$ISSUE" "## Implementador: $REASON

$SUMMARY

$DESCRIPTION"
  fi
  wt_remove "$WT"
  exit 0
fi

# ── Commit + push ──────────────────────────────────────────────────────────
# Only the Flutter package: the harness and CI live outside it and the
# implementer is told not to touch them, so scoping the add enforces it.
git -C "$WT" add -A -- "$FLUTTER_SUBDIR" >/dev/null 2>&1 || true
git -C "$WT" -c user.name="qa-implementer" -c user.email="qa@local" \
  commit -m "$BRANCH: $SUMMARY (#$ISSUE)" >/dev/null 2>&1 || true

if ! git -C "$WT" push -u origin "$BRANCH" --force >/dev/null 2>&1; then
  log "ERRO: push falhou"
  set_state "$ISSUE" "$L_HUMAN"
  comment_issue "$ISSUE" "## Implementador: push falhou

O código foi escrito mas não chegou ao remoto. Branch: \`$BRANCH\`."
  wt_remove "$WT"
  exit 1
fi
log "push ok -> $BRANCH"

# ── PR into dev ────────────────────────────────────────────────────────────
# `Fixes #N` is mandatory: pr-governance.yml enforces it, and the verifier reads
# it to find its way back to the issue.
PR_BODY=$(cat <<EOF
## Resumo

$SUMMARY

$DESCRIPTION

## Testes

$TESTS

## Linked Issue

Fixes #$ISSUE
EOF
)

EXISTING_PR=$(gh pr list --repo "$REPO" --head "$BRANCH" --base "$BASE_BRANCH" \
  --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")

if [ -n "$EXISTING_PR" ]; then
  gh pr edit "$EXISTING_PR" --repo "$REPO" \
    --title "$SUMMARY (#$ISSUE)" --body "$PR_BODY" >/dev/null 2>&1 || true
  gh pr comment "$EXISTING_PR" --repo "$REPO" --body "## Implementador: retrabalho submetido

$SUMMARY

Testes: $TESTS" >/dev/null 2>&1 || true
  PR_NUM="$EXISTING_PR"
  log "PR #$PR_NUM actualizado"
else
  # REST API, not `gh pr create`: the latter dies on this repo over Projects-classic
  # deprecation, leaving the pushed branch with no PR and the issue on needs-human.
  PR_NUM=$(create_pr_api "$BRANCH" "$BASE_BRANCH" "$SUMMARY (#$ISSUE)" "$PR_BODY" || echo "")
  if [ -z "$PR_NUM" ]; then
    log "ERRO: PR não criado"
    set_state "$ISSUE" "$L_HUMAN"
    comment_issue "$ISSUE" "## Implementador: PR não criado

O branch \`$BRANCH\` foi enviado mas o PR para \`$BASE_BRANCH\` não foi aberto."
    wt_remove "$WT"
    exit 1
  fi
  log "PR criado: $PR_URL"
fi

comment_issue "$ISSUE" "## Implementador: implementado

$SUMMARY

Testes: $TESTS

PR: #$PR_NUM (\`$BRANCH\` → \`$BASE_BRANCH\`)"
set_state "$ISSUE" "$L_REVIEW"

rm -f "$VERDICT_FILE"
wt_remove "$WT"
log "done #$ISSUE -> $L_REVIEW (PR #$PR_NUM)"
