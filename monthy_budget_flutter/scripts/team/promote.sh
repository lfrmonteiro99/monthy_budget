#!/bin/bash
# promote.sh — open and land the `dev` -> `main` PR once the backlog is drained.
#
# WHY THIS IS NOT OPTIONAL. The critic tests `main`; fixes land on `dev`. If dev
# were never promoted, `main` would never improve, and every critic run would
# re-discover the same defects it found last time. De-duplication would quietly
# swallow them and the pipeline would look busy while shipping nothing. Promotion
# is what turns the loop into progress instead of a treadmill.
#
# Runs only when the backlog is empty, i.e. every issue is closed or parked on a
# human — so `dev` contains nothing half-finished at the moment it is promoted.
#
# Usage: promote.sh [--dry-run]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="promote"

DRY=0
for a in "$@"; do [ "$a" = "--dry-run" ] && DRY=1; done

git -C "$TEAM_ROOT" fetch origin "$PROD_BRANCH" "$BASE_BRANCH" >/dev/null 2>&1 || true

DEV_SHA=$(git -C "$TEAM_ROOT" rev-parse --verify --quiet "origin/$BASE_BRANCH" || echo "")
MAIN_SHA=$(git -C "$TEAM_ROOT" rev-parse --verify --quiet "origin/$PROD_BRANCH" || echo "")

if [ -z "$DEV_SHA" ] || [ -z "$MAIN_SHA" ]; then
  log "ERRO: não resolvi as refs de $BASE_BRANCH / $PROD_BRANCH"
  exit 1
fi

if [ "$DEV_SHA" = "$MAIN_SHA" ]; then
  log "$BASE_BRANCH == $PROD_BRANCH — nada a promover"
  exit 0
fi

# Commits on dev that main does not have yet.
AHEAD=$(git -C "$TEAM_ROOT" rev-list --count "origin/$PROD_BRANCH..origin/$BASE_BRANCH" 2>/dev/null || echo 0)
BEHIND=$(git -C "$TEAM_ROOT" rev-list --count "origin/$BASE_BRANCH..origin/$PROD_BRANCH" 2>/dev/null || echo 0)
log "$BASE_BRANCH está $AHEAD à frente e $BEHIND atrás de $PROD_BRANCH"

if [ "$AHEAD" -eq 0 ]; then
  log "nada novo em $BASE_BRANCH — nada a promover"
  exit 0
fi

# main moved on its own (a hand-made commit). Bring it into dev first, otherwise
# the PR is BEHIND and, with this repo's protection rules, will never merge —
# a stall this project has hit before.
if [ "$BEHIND" -gt 0 ]; then
  log "$PROD_BRANCH avançou — a integrar em $BASE_BRANCH antes de promover"
  WT=$(wt_checkout "$BASE_BRANCH" "promote-sync") || { log "ERRO: checkout falhou"; exit 1; }
  # `-X ours` resolves CONFLICTING HUNKS in dev's favour while still taking
  # everything main has that dev lacks. That is exactly right here, and the reason is
  # structural rather than a preference:
  #
  # main receives dev's work as a SQUASH commit. Git cannot tell that main's squashed
  # hunk and dev's original commits are the same change, so merging main back into dev
  # conflicts on every file the promotion touched — the two sides are identical work
  # wearing different shapes. Taking dev's side on those is a no-op in content terms.
  # Meanwhile main also carries commits dev has never seen (the harness itself lands
  # on main directly), and `-X ours` still merges those normally — which `-s ours`
  # would silently discard.
  #
  # Without this the sync failed outright and the promotion stopped, which for an
  # unattended pipeline means it stops forever.
  if git -C "$WT" -c user.name="qa-promote" -c user.email="qa@local" \
       merge --no-edit -X ours "origin/$PROD_BRANCH" >/dev/null 2>&1; then
    # Detached checkout: push the resulting commit onto the dev ref explicitly.
    if git -C "$WT" push origin "HEAD:refs/heads/$BASE_BRANCH" >/dev/null 2>&1; then
      log "$PROD_BRANCH integrado em $BASE_BRANCH"
    else
      log "ERRO: push da integração falhou"
      wt_remove "$WT"; exit 1
    fi
  else
    # Even -X ours could not finish (add/add on a file neither side can reconcile,
    # or a deleted/modified pair). Leave dev untouched and say what to look at — but
    # do NOT stop the pipeline: the promotion simply waits for the next cycle, by
    # which time the queue has usually moved the conflicting file along anyway.
    CONFLICTED=$(git -C "$WT" diff --name-only --diff-filter=U 2>/dev/null | tr '\n' ' ')
    log "conflito irreconciliável ao integrar $PROD_BRANCH em $BASE_BRANCH: ${CONFLICTED:-?}"
    log "  $BASE_BRANCH fica intacto; a promoção repete no próximo ciclo"
    git -C "$WT" merge --abort >/dev/null 2>&1 || true
    wt_remove "$WT"; exit 0
  fi
  wt_remove "$WT"
  git -C "$TEAM_ROOT" fetch origin "$BASE_BRANCH" >/dev/null 2>&1 || true
fi

# ── Nothing to promote is decided by CONTENT, not by commit count ──────────
#
# The promotion is squash-merged, so dev's original commits never become ancestors
# of main. dev therefore reports AHEAD forever while its content is already shipped,
# and the cadence check opens a PR with an EMPTY DIFF every cycle. #1263 and #1265
# were exactly that: 0 files, 0 lines, each burning a full CI run across 8 checks.
#
# The realign at the bottom of this script was supposed to prevent it, and could
# not: it reads the PR's state immediately after arming `--auto`, when the PR is
# necessarily still OPEN because CI has not run yet. "Not merged yet" was read as
# "will not merge", so the realign never fired for the only merge mode this repo
# uses. Checking here instead makes it independent of WHEN the merge happens — the
# next cycle sees the empty diff and realigns, whenever that is.
git -C "$TEAM_ROOT" fetch origin "$PROD_BRANCH" "$BASE_BRANCH" >/dev/null 2>&1 || true
if [ -z "$(git -C "$TEAM_ROOT" diff "origin/$PROD_BRANCH" "origin/$BASE_BRANCH" 2>/dev/null)" ]; then
  log "$BASE_BRANCH está $AHEAD commit(s) à frente mas o conteúdo é idêntico a $PROD_BRANCH"
  log "  — promoção vazia evitada"
  # This branch sits ABOVE the dry-run guard further down, so it has to honour
  # --dry-run itself. Without this, `--dry-run` would push for real.
  if [ "$DRY" = "1" ]; then
    log "  [dry-run] realinharia $BASE_BRANCH com $PROD_BRANCH e não abriria PR"
    exit 0
  fi
  # Safe by construction: only ever reached when the diff is empty, so this can
  # never discard work that has not shipped.
  if git -C "$TEAM_ROOT" push --force-with-lease origin \
       "origin/$PROD_BRANCH:refs/heads/$BASE_BRANCH" >/dev/null 2>&1; then
    log "  $BASE_BRANCH realinhado com $PROD_BRANCH"
  else
    log "  AVISO: realinhamento falhou — a promoção vazia repete no próximo ciclo"
  fi
  # An empty PR already open would sit there forever consuming CI on every push.
  STALE=$(gh pr list --repo "$REPO" --head "$BASE_BRANCH" --base "$PROD_BRANCH" \
    --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")
  if [ -n "$STALE" ]; then
    gh pr close "$STALE" --repo "$REPO" --comment "Fechado pelo orquestrador: o diff\
 para \`$PROD_BRANCH\` está vazio — este conteúdo já foi promovido e \`$BASE_BRANCH\`\
 foi realinhado." >/dev/null 2>&1 \
      && log "  PR de promoção vazio #$STALE fechado"
  fi
  exit 0
fi

COMMITS=$(git -C "$TEAM_ROOT" log --pretty='- %s' "origin/$PROD_BRANCH..origin/$BASE_BRANCH" 2>/dev/null | head -40)

# Issues delivered by this promotion, taken from the commit subjects. They are
# already closed by the verifier; naming them here is what satisfies the repo's
# PR governance (a closing keyword is mandatory on PRs into main) and it is
# honest — this PR really is what ships those fixes.
ISSUES=$(printf '%s\n' "$COMMITS" | grep -oE '#[0-9]+' | grep -oE '[0-9]+' | sort -n -u | head -20)
FIXES=""
for i in $ISSUES; do FIXES="$FIXES
Fixes #$i"; done

# Never invent a closing keyword. A promotion whose commits reference no issue
# is a real anomaly (the implementer always writes `#N`), and emitting something
# like `Fixes #0` to satisfy the governance check would make the PR claim to
# close an issue that does not exist. Better to let governance fail loudly.
if [ -z "${ISSUES//[[:space:]]/}" ]; then
  log "AVISO: nenhum issue referenciado nos commits — o check validate-pr vai reprovar"
fi

# feat: anywhere in the range means a minor bump; the repo's release-tag.yml
# reads this label to compute the CalVer.
RELEASE_LABEL="release:patch"
if printf '%s\n' "$COMMITS" | grep -qiE '(^|\s)feat(\(|:)'; then RELEASE_LABEL="release:minor"; fi
if printf '%s\n' "$COMMITS" | grep -qiE 'BREAKING CHANGE|^[a-zA-Z]+!:'; then RELEASE_LABEL="release:major"; fi

BODY=$(cat <<EOF
## Summary

Promoção automática de \`$BASE_BRANCH\` para \`$PROD_BRANCH\`: $AHEAD commit(s)
com correções que passaram review **e** verificação de QA na app a correr.

## Release Notes

$COMMITS

## Linked Issue
$FIXES
EOF
)

if [ "$DRY" = "1" ]; then
  log "[dry-run] abriria PR $BASE_BRANCH -> $PROD_BRANCH com label $RELEASE_LABEL"
  printf '%s\n' "$BODY"
  exit 0
fi

EXISTING=$(gh pr list --repo "$REPO" --head "$BASE_BRANCH" --base "$PROD_BRANCH" \
  --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
  PR="$EXISTING"
  gh pr edit "$PR" --repo "$REPO" --body "$BODY" >/dev/null 2>&1 || true
  add_label_api "$PR" "$RELEASE_LABEL"
  log "PR de promoção #$PR actualizado"
else
  URL=$(gh pr create --repo "$REPO" --base "$PROD_BRANCH" --head "$BASE_BRANCH" \
    --title "QA: promover $BASE_BRANCH para $PROD_BRANCH ($AHEAD commit(s))" \
    --body "$BODY" 2>/dev/null || echo "")
  PR=$(printf '%s' "$URL" | grep -oE '[0-9]+$' || echo "")
  if [ -z "$PR" ]; then
    log "ERRO: não abri o PR de promoção"
    exit 1
  fi
  add_label_api "$PR" "$RELEASE_LABEL"
  log "PR de promoção criado: $URL ($RELEASE_LABEL)"
fi

# --auto so it lands as soon as `test` and `validate-pr` go green. main enforces
# those for admins too, so there is no way to shortcut them and no reason to try.
if gh pr merge "$PR" --repo "$REPO" --squash --auto >/dev/null 2>&1; then
  log "auto-merge armado no PR #$PR"
else
  log "AVISO: não consegui armar o auto-merge no PR #$PR — ver os gates"
fi

# ── Close the cycle: realign dev onto main after the promotion lands ────────
#
# The promotion is SQUASH-merged, to match how everything else lands in this repo.
# That means dev's individual commits never become ancestors of main, so straight
# after a successful promotion git reports dev as both AHEAD (its original commits)
# and BEHIND (main's squash commit) — while the CONTENT of the two is identical.
#
# Left alone, the next cycle sees AHEAD > 0, opens another promotion PR with an
# empty diff, and does so forever. Verified: right after #1245 landed, dev was
# "5 ahead" of main with `git diff origin/main origin/dev` completely empty.
#
# dev is a staging branch, not a history worth preserving, so once its content is
# in main the honest state is "identical" — reset the ref. Only ever done when the
# diff is genuinely empty, so this can never discard unpromoted work.
# NOTE: this is only a FAST PATH, for the rare case where the PR is already merged
# by the time we look. It cannot be the guard, because with `--auto` the PR is still
# OPEN here in every normal run — CI has not finished. The real guard is the
# empty-diff check above, which does not depend on when the merge happens.
if [ "$(gh pr view "$PR" --repo "$REPO" --json state --jq .state 2>/dev/null)" = "MERGED" ]; then
  git -C "$TEAM_ROOT" fetch origin "$PROD_BRANCH" "$BASE_BRANCH" >/dev/null 2>&1 || true
  if [ -z "$(git -C "$TEAM_ROOT" diff "origin/$PROD_BRANCH" "origin/$BASE_BRANCH" 2>/dev/null)" ]; then
    if git -C "$TEAM_ROOT" push --force-with-lease origin \
         "origin/$PROD_BRANCH:refs/heads/$BASE_BRANCH" >/dev/null 2>&1; then
      log "$BASE_BRANCH realinhado com $PROD_BRANCH (conteúdo já era idêntico)"
    else
      log "AVISO: não consegui realinhar $BASE_BRANCH — próximo ciclo pode abrir um PR vazio"
    fi
  else
    log "$BASE_BRANCH ainda difere de $PROD_BRANCH em conteúdo — não realinho"
  fi
fi

log "done"
