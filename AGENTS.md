# Agent Workflow Rules (Repository Root)

These rules are mandatory for any agent/model that edits this repository.

## Required task flow (must follow)
1. Receive user prompt for code change.
2. Check if a GitHub issue already exists for the task.
3. If issue does not exist, create one with proper scope + acceptance criteria.
4. Create/use a work branch named with the issue number (example: `issue-123-short-description`).
5. Implement code changes.
6. Create/update tests for changed behavior.
7. Commit and push to the work branch (never push code directly to `main`).
8. Pipeline runs checks.
9. If checks pass, PR is created automatically and merged automatically into `main`.

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
- Include `#<issue-number>` in commit messages so the pipeline can link the PR.

## Operational rules
- Always include issue reference in PR body (`Fixes #<issue-number>`).
- PR body must include `## Release Notes`.
- PR must carry one release label (`release:patch|release:minor|release:major`).
- Active workflows are in repo root: `.github/workflows/*`.
- Flutter app code lives in `monthy_budget_flutter/`.

## Calm redesign — source of truth (handoff v3)
For any UI redesign work in `monthy_budget_flutter/`:
- `monthy_budget_flutter/docs/calm-handoff.md` — foundation (tokens, typography, layout patterns, coherence checklist).
- `monthy_budget_flutter/docs/calm-screen-rollout.md` — per-screen operational spec (8 fixed blocks per screen). **Cite the relevant entry verbatim in the issue body**; do not paraphrase.
- `.github/PULL_REQUEST_TEMPLATE.md` — Calm-aware PR gate. Every redesign PR must check the relevant boxes.

Past waves passed CI with shallow token-swaps that didn't restructure. The rollout doc + PR template are how that gap closes. Do not dispatch redesign work with prose-only briefs.