#!/bin/bash
# premerge.sh — the PRE-MERGE BROWSER GATE. Runs after the reviewer approves and
# BEFORE the PR is integrated: it builds the PR's own branch, drives the real app
# against the issue's acceptance criteria, and only then merges.
#
# WHY THIS EXISTS. The reviewer reads the diff and runs the suite. Neither shows
# whether the app works — only driving the UI does. That test already existed, but
# it ran AFTER the merge, and the pipeline has no revert: when the post-merge
# verifier failed, the broken commit stayed in `dev` while the issue went back to
# `qa:blocked-impl`. Worse, `maybe_promote` only defers promotion for issues in
# `qa:verify`, so a fix already PROVEN broken could ride a promotion into `main`
# while its re-fix was still queued. Testing before the merge closes both by
# construction: nothing reaches `dev` without having been driven in a browser.
#
# The post-merge verifier is deliberately kept — this gate proves the fix works in
# isolation, the verifier proves it still works once integrated alongside the other
# fixes on `dev`. Different questions.
#
# Order matters: the test runs FIRST because `gh pr merge --delete-branch` deletes
# the very branch being tested.
#
#   pass       -> merge into dev, issue -> qa:verify
#   fail-impl  -> qa:blocked-impl, PR stays OPEN, branch NOT deleted
#   fail-spec  -> qa:blocked-spec
#   no verdict -> stays qa:premerge. Never merges by omission: silence is not consent.
#
# Usage: premerge.sh <issue_number>
set -uo pipefail

ISSUE="${1:?issue obrigatorio}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="premerge"

VERDICT_FILE="$VERDICT_DIR/premerge-$ISSUE.json"
MODEL="${PREMERGE_MODEL:-sonnet}"
export UI_TESTER_MODEL="$MODEL"
export UI_TESTER_TIMEOUT="${PREMERGE_TIMEOUT:-1800}"

# ── Find the PR this issue is waiting on ───────────────────────────────────
# The implementer's branch is qa/issue-N by construction, but the PR is the
# authority: a branch with no open PR has nothing to gate.
PR_JSON=$(gh pr list --repo "$REPO" --state open --limit 100 \
  --json number,headRefName,baseRefName,state 2>/dev/null) \
  || { log "ERRO: não consegui listar PRs"; exit 1; }

PR=$(printf '%s' "$PR_JSON" | jq -r --arg b "qa/issue-$ISSUE" \
  '[.[] | select(.headRefName == $b)] | .[0].number // empty')

if [ -z "$PR" ]; then
  # No open PR and the issue sits in qa:premerge: either the merge already landed
  # on a previous run that died after merging, or the PR was closed by hand. Both
  # are recoverable states the ORCHESTRATOR should resolve — say which, and stop.
  log "ERRO: nenhum PR aberto com head 'qa/issue-$ISSUE'"
  comment_issue "$ISSUE" "## Gate pré-merge: sem PR aberto

Este issue está em \`$L_PREMERGE\` mas não existe PR aberto com head
\`qa/issue-$ISSUE\`. Ou o merge já aconteceu numa corrida anterior, ou o PR foi
fechado à mão. Devolvido ao implementador para reabrir o trabalho."
  set_state "$ISSUE" "$L_BLOCKED_IMPL"
  exit 1
fi

BRANCH="qa/issue-$ISSUE"
BASE=$(printf '%s' "$PR_JSON" | jq -r --arg n "$PR" '[.[] | select(.number == ($n|tonumber))] | .[0].baseRefName // empty')
log "issue #$ISSUE PR #$PR branch=$BRANCH -> $BASE porta=$PORT_PREMERGE modelo=$MODEL"

# ── Always tear the branch build down ──────────────────────────────────────
# One serve worktree and one dev server PER PR. Left behind they accumulate a
# full Flutter web build each, and the port stays bound so the next gate silently
# tests the previous PR's bundle.
cleanup_serve() {
  bash "$SCRIPT_DIR/serve-app.sh" "$BRANCH" --port "$PORT_PREMERGE" --stop >/dev/null 2>&1 || true
  local slug; slug=$(printf '%s' "$BRANCH" | tr -c 'a-zA-Z0-9._-' '-')
  git -C "$TEAM_ROOT" worktree remove --force "$WT_ROOT/serve-$slug" >/dev/null 2>&1 || true
}
trap cleanup_serve EXIT

STAGE_CONTEXT="És o **tester de QA que guarda o merge**. Um defeito foi reportado, analisado e
corrigido, e o reviewer aprovou o código — mas o fix **ainda não está integrado**:
vive apenas no branch do PR que estás a testar.

O teu trabalho é **provar na app a correr** que o defeito está mesmo resolvido. Se
aprovares, o PR é integrado em \`$BASE\`; se reprovares, o PR fica aberto e volta a
quem o escreveu. **Nada entra em \`$BASE\` sem passar por ti** — por isso, na dúvida,
reprova: um fix que volta atrás custa uma iteração, um fix partido que entra custa
uma promoção inteira."

run_ui_tester "$ISSUE" "$BRANCH" "$PORT_PREMERGE" "$VERDICT_FILE" premerge "$STAGE_CONTEXT"
TESTER_RC=$?

case "$TESTER_RC" in
  1)
    log "ERRO: ambiente falhou — fica em $L_PREMERGE para nova tentativa"
    comment_issue "$ISSUE" "## Gate pré-merge: não consegui testar a app

Não foi possível compilar, servir ou instrumentar \`$BRANCH\`. Isto é do ambiente,
não do fix — o PR #$PR fica aberto e o issue em \`$L_PREMERGE\` para nova passagem."
    exit 1
    ;;
  2)
    log "SEM VEREDICTO (corrida degradada) — fica em $L_PREMERGE"
    comment_issue "$ISSUE" "## Gate pré-merge: corrida degradada, sem veredicto

A corrida não produziu veredicto por uma razão alheia ao issue: a subscrição
estava esgotada e o modelo de fallback não conseguiu concluir o teste. O merge
**não** foi feito. Fica em \`$L_PREMERGE\` para nova tentativa."
    exit 0
    ;;
  3)
    # No verdict on a healthy run. Requeueing to the same state is right until
    # the run has burned the whole clock twice — see note_verdictless_run.
    if N=$(note_verdictless_run "$ISSUE" "$UI_TESTER_LAST_RC"); then
      log "SEM VEREDICTO — fica em $L_PREMERGE para nova tentativa"
      comment_issue "$ISSUE" "## Gate pré-merge: corrida sem veredicto

A corrida terminou sem escrever veredicto (ver \`$UI_TESTER_LOG\`). Falha da
corrida, não do fix — o merge **não** foi feito e o issue volta à fila do gate."
    else
      log "SEM VEREDICTO pela ${MAX_TIMEOUTS}.ª vez por timeout — a devolver ao curator"
      comment_issue "$ISSUE" "$(verdictless_escalation_body "gate pré-merge" "$MAX_TIMEOUTS" "${PREMERGE_TIMEOUT:-1800}")"
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

log "verdict=$VERDICT"

case "$VERDICT" in
  pass)
    gh pr comment "$PR" --repo "$REPO" --body "## Gate pré-merge: aprovado na app ✅

$SUMMARY$CRITERIA$REGRESSIONS

Testado no browser a partir de \`$BRANCH\` (o código deste PR, ainda não integrado).
A integrar em \`$BASE\`." >/dev/null 2>&1 || true

    # Whether the merge happened is decided by READING the PR, never by trusting an
    # exit code. `gh pr merge` returns non-zero for things that occur AFTER a
    # successful merge — deleting the branch, for one — and reports "already merged"
    # as an error. Observed on PR #1239: the admin merge landed, gh returned
    # non-zero, the script recorded a failure and queued a redo of integrated work.
    merge_landed() {
      [ "$(gh pr view "$PR" --repo "$REPO" --json state --jq .state 2>/dev/null)" = "MERGED" ]
    }

    MERGE_OK=0
    gh pr merge "$PR" --repo "$REPO" --squash --delete-branch >/dev/null 2>&1 || true
    if merge_landed; then
      MERGE_OK=1
    else
      MSTATUS=$(gh pr view "$PR" --repo "$REPO" --json mergeStateStatus --jq .mergeStateStatus 2>/dev/null || echo "")
      # The reviewer's own suite result, recorded when it approved. Read from state
      # because its verdict file is deleted at the end of the review run.
      TESTS_OK=$(cat "$STATE_DIR/review-tests-pass-$PR" 2>/dev/null || echo "false")
      log "merge recusado (mergeStateStatus=$MSTATUS, reviewer tests_pass=$TESTS_OK)"
      case "$MSTATUS" in
        DIRTY|BEHIND|BLOCKED)
          # A conflicted or stale branch is NOT bad code — the review and the browser
          # test both passed. Say so, so the implementer resolves the conflict
          # instead of re-doing accepted work.
          gh pr comment "$PR" --repo "$REPO" --body "## Gate pré-merge: aprovado, mas o branch não integra (\`$MSTATUS\`)

O código foi **aprovado e validado na app** — o problema é só que o branch não
integra em \`$BASE\`, por conflito ou por estar atrasado.

**Não refaças o trabalho.** Na próxima passagem o \`$BASE\` é integrado neste branch
e, se houver conflito, os marcadores ficam na árvore para resolveres por intenção:
percebe o que cada lado queria e preserva as duas intenções. Depois corre a suite
completa e reenvia." >/dev/null 2>&1 || true
          ;;
        *)
          # `gh pr merge` refuses while any check is red, and these checks go red on
          # GitHub infrastructure (429/503 downloading the flutter action) as readily
          # as on real failures. At this point the code has been read, the suite has
          # run, AND the app has been driven in a browser — a flaked CI job is not a
          # reason to block. `dev` is unprotected staging; `main` keeps its gates.
          if [ "$TESTS_OK" = "true" ] && [ "$BASE" = "$BASE_BRANCH" ]; then
            log "checks instáveis mas o reviewer correu a suite e o gate passou — a concluir o merge"
            gh pr comment "$PR" --repo "$REPO" --body "## Gate pré-merge: merge concluído apesar de checks instáveis

O \`gh pr merge\` foi recusado por estado de checks (\`$MSTATUS\`), não por
conflito. Os workflows falharam a descarregar a \`flutter-action\` (429/503 da
infraestrutura do GitHub), o que não diz nada sobre este código.

Este código foi lido pelo reviewer, passou \`flutter analyze\` e a suite completa, e
foi agora **conduzido no browser** a partir do próprio branch do PR. \`$BASE\` é
staging de QA sem protecção, por isso o merge foi concluído. O \`main\` mantém as
suas protecções intactas." >/dev/null 2>&1 || true
            gh pr merge "$PR" --repo "$REPO" --squash --delete-branch --admin >/dev/null 2>&1 || true
            merge_landed && MERGE_OK=1
          fi
          ;;
      esac
    fi

    rm -f "$STATE_DIR/review-tests-pass-$PR"

    if [ "$MERGE_OK" = "1" ]; then
      log "PR #$PR integrado em $BASE"
      # NOT closed here. The issue closes only after the verifier re-tests it on the
      # running dev build: this gate proved the fix works alone, not that it survives
      # integration alongside everything else that landed.
      comment_issue "$ISSUE" "## Gate pré-merge: aprovado e integrado

$SUMMARY$CRITERIA$REGRESSIONS

Validado no browser a partir de \`$BRANCH\` **antes** do merge. PR #$PR integrado em
\`$BASE\`. Em espera de verificação de integração em \`$BASE\`."
      set_state "$ISSUE" "$L_VERIFY"
    else
      log "merge falhou (conflito ou gate)"
      comment_issue "$ISSUE" "## Gate pré-merge: aprovado na app, mas o merge falhou

O fix foi validado no browser, mas o branch não integra em \`$BASE\` — conflito ou
gate em falta. O implementador tem de actualizar o branch; o trabalho de correcção
em si está aceite."
      set_state "$ISSUE" "$L_BLOCKED_IMPL"
    fi
    ;;

  fail-impl)
    gh pr comment "$PR" --repo "$REPO" --body "## Gate pré-merge: reprovado na app ❌

$SUMMARY$CRITERIA$REGRESSIONS

O código foi aprovado na leitura, mas o defeito **continua presente na app a
correr**. O PR fica aberto: corrige neste mesmo branch." >/dev/null 2>&1 || true
    comment_issue "$ISSUE" "## Gate pré-merge: reprovado ❌ — a correção não resolve

$SUMMARY$CRITERIA$REGRESSIONS

Testado no browser a partir de \`$BRANCH\`, **antes** de integrar. Nada entrou em
\`$BASE\`. O PR #$PR fica aberto e o branch intacto — continua o trabalho aí."
    set_state "$ISSUE" "$L_BLOCKED_IMPL"
    log "#$ISSUE -> $L_BLOCKED_IMPL (PR #$PR mantido aberto)"
    ;;

  fail-spec)
    gh pr comment "$PR" --repo "$REPO" --body "## Gate pré-merge: reprovado — o briefing estava errado ❌

$SUMMARY$CRITERIA$REGRESSIONS

A implementação cumpre os critérios e o defeito persiste. O PR fica aberto
enquanto o curator reanalisa." >/dev/null 2>&1 || true
    comment_issue "$ISSUE" "## Gate pré-merge: reprovado ❌ — o briefing estava errado

$SUMMARY$CRITERIA$REGRESSIONS

A implementação cumpriu os critérios e o defeito persiste na app: os critérios não
atacavam a causa. Nada entrou em \`$BASE\`. Devolvido ao curator para reanalisar."
    set_state "$ISSUE" "$L_BLOCKED_SPEC"
    log "#$ISSUE -> $L_BLOCKED_SPEC (PR #$PR mantido aberto)"
    ;;

  *)
    # An unusable verdict is not permission to merge. The fix is undemonstrated,
    # which is the implementer's to answer — with the PR still open.
    comment_issue "$ISSUE" "## Gate pré-merge: resultado não reconhecido (\`$VERDICT\`)

$SUMMARY$CRITERIA

O veredicto não usou um dos resultados válidos. Como o fix não ficou demonstrado,
**não** foi integrado e volta ao implementador."
    set_state "$ISSUE" "$L_BLOCKED_IMPL"
    log "#$ISSUE -> $L_BLOCKED_IMPL (veredicto inválido, sem merge)"
    ;;
esac

rm -f "$VERDICT_FILE"
log "done #$ISSUE"
