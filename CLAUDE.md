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

## Hard rule
- Never push code directly to `main`.