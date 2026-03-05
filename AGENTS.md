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

## Operational rules
- Always include issue reference in PR body (`Fixes #<issue-number>`).
- PR body must include `## Release Notes`.
- PR must carry one release label (`release:patch|release:minor|release:major`).
- Active workflows are in repo root: `.github/workflows/*`.
- Flutter app code lives in `monthy_budget_flutter/`.