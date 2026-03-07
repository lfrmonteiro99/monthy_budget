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