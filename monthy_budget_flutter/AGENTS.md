# Agent Workflow Rules

These rules are mandatory for any agent/model that edits this repository.

## Required task flow (must follow)
1. Receive user prompt for code change.
2. Check if a GitHub issue already exists for the task.
3. If issue does not exist, create one with proper scope + acceptance criteria.
4. Implement code changes.
5. Create/update tests for changed behavior.
6. Commit and push to a work branch.
7. Pipeline runs tests.
8. If tests pass, PR is created automatically and merged automatically into `main`.

## Operational rules
- Always include issue reference in PR body (`Fixes #<issue-number>`).
- PR body must include `## Release Notes`.
- PR must carry one release label (`release:patch|release:minor|release:major`).
- The workflow `.github/workflows/agent-delivery.yml` automates issue creation fallback, PR creation, labeling, and merge after successful tests.

## Versioning and release
- CalVer `YYYY.M.PATCH`
- `versionCode = (YY * 10000000) + (MM * 100000) + PATCH`
- Tag: `vYYYY.M.PATCH`
- Release script: `bash scripts/release.sh [--dry-run] [--allow-dirty] [--bump patch|minor|major]`
