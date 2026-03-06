# Project Agent Instructions

## Mandatory Issue Workflow
1. Any code-change request must map to a GitHub issue.
2. If no issue exists, create one (or use `bash scripts/create_or_get_issue.sh`).
3. Work must be linked to an issue in PR body (`Fixes #N`).

## Required delivery flow
1. Prompt received
2. Check/create issue
3. Implement code
4. Update/create tests
5. Commit + push to branch
6. Pipeline runs analyze/tests
7. On success, automation creates PR and merges into `main`

This is automated by `.github/workflows/agent-delivery.yml`.

## PR content requirements
- `## Linked Issue` with `Fixes #N`
- `## Release Notes` with human-readable summary
- Exactly one release label: `release:patch|release:minor|release:major`

## Versioning / release
- CalVer `YYYY.M.PATCH`
- versionCode formula: `(YY * 10000000) + (MM * 100000) + PATCH`
- Tag: `vYYYY.M.PATCH`
- Release command:
  - `bash scripts/release.sh [--dry-run] [--allow-dirty] [--bump patch|minor|major]`
