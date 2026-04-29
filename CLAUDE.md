# Project Agent Instructions (Repository Root)

## Mandatory Issue Workflow
1. Any code-change request must map to a GitHub issue.
2. If no issue exists, create one before code edits.
3. Branch name must include the issue number (`issue-<n>-...`).
4. Work must be linked in PR body (`Fixes #N`).

## Required delivery flow
1. Prompt received
2. Check/create issue
3. Implement code + tests on feature branch
4. Commit + push
5. Pipeline checks
6. PR auto-created and auto-merged after checks

## Branch management rules
- **Always** create new branches from `origin/main`:
  ```bash
  git fetch origin main && git checkout -b <branch-name> origin/main
  ```
- **Before pushing**, always update the branch with the latest `origin/main`:
  ```bash
  git fetch origin main && git rebase origin/main
  ```
- If rebase causes conflicts, resolve them before pushing.
- Never push code directly to `main`.
- Include `#<issue-number>` in commit messages so the pipeline can link the PR.

## Calm redesign — source of truth (handoff v3)
For any UI redesign work in `monthy_budget_flutter/`, these three docs are canonical:
- `monthy_budget_flutter/docs/calm-handoff.md` — foundation: tokens (§2), typography (§3), layout patterns (§4), coherence checklist (§7).
- `monthy_budget_flutter/docs/calm-screen-rollout.md` — **per-screen operational spec**. Each screen has 8 fixed blocks (issue+branch, files, mock+artboard, input data, structure top→bottom with copy/sizes/tokens, interactions, states, regression checklist). Cite the relevant entry verbatim in the issue body — paraphrasing produces shallow migrations.
- `.github/PULL_REQUEST_TEMPLATE.md` — comprehensive Calm-aware PR gate. Every redesign PR must check the relevant boxes (foundation, design tokens, typography, states, animations, a11y, screen-specific, migration, visual review).

Vague briefs ("rewrite on Calm widgets") are gameable — past waves passed CI with token-swaps that didn't restructure. The rollout doc + PR template are the gate that closes that gap. Do not reopen redesign issues with prose-only briefs.