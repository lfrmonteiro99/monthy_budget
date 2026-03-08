# Claude Code Guidelines

## Commit Messages

When working on a GitHub issue, **always** include a closing keyword referencing the issue number in your commit message. This is how the CI pipeline links PRs to issues and auto-closes them on merge.

Use one of these keywords followed by the issue number:
- `Closes #123`
- `Fixes #123`
- `Resolves #123`

Example commit messages:
```
Add dark mode toggle to settings screen

Closes #42
```

```
Fix savings goal contribution rounding error

Fixes #87
```

The CI pipeline (`flutter-ci.yml`) automatically creates PRs and extracts these references from commit messages into the PR body. When the PR is merged, the linked issues are closed automatically.
