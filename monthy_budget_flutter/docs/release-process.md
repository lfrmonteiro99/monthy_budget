# Release Management

## Versioning
- CalVer: `YYYY.M.PATCH`
- versionCode: `(YY * 10000000) + (MM * 100000) + PATCH`
- Tag: `vYYYY.M.PATCH`

Example: `2026.3.11` → versionCode `260300011`, tag `v2026.3.11`

## How to release

From `main`, run:

```bash
bash scripts/release.sh [--dry-run] [--allow-dirty] [--bump patch|minor|major]
```

### What the script does

1. Computes next version from existing tags + commit history
2. Creates branch `release/vYYYY.M.PATCH`
3. Updates `pubspec.yaml` version
4. Generates `CHANGELOG.md` via `git-cliff`
5. Commits, pushes branch
6. Creates GitHub issue ("Release vX.Y.Z")
7. Creates PR with `Fixes #N`, `release:*` label, and `## Release Notes`

### What happens after

1. `agent-delivery.yml` runs tests on the release branch
2. `pr-governance.yml` validates the PR body
3. PR is auto-merged (or manually merged)
4. `release-tag.yml` triggers on merge:
   - Creates git tag on the **merge commit** (not orphaned)
   - Creates GitHub Release with changelog body

### Prerequisites

- `git-cliff` installed (`npm i -g git-cliff`)
- `gh` CLI authenticated (`gh auth login`)
- Clean working tree (or `--allow-dirty`)
- Must be on `main` branch

### Dry run

```bash
bash scripts/release.sh --dry-run --bump patch
```

Prints version info without modifying files or creating branches/PRs.
