# Monthy Budget

Monthy Budget is a Portuguese monthly budget calculator with built-in IRS tax
tables, recurring expense tracking, a meal planner, grocery/shopping lists, and
an AI coach. The main product is a Flutter mobile app backed by Supabase, with
supporting Python scrapers that build country-specific grocery price bundles.

## Repository layout

| Path | Purpose |
|------|---------|
| `monthy_budget_flutter/` | Flutter client (Android, iOS, web). Main product code. |
| `scrapers/` | Python scrapers + bundle builder for grocery price data (Continente, Pingo Doce, Auchan, Mercadona, Carrefour ES, Open Food Facts, DECO). |
| `docs/` | Public-facing site assets: landing page, privacy policy, terms, release guide, offline assets. |
| `.github/workflows/` | CI/CD pipelines: Flutter CI, quality gates, grocery scrape jobs, Supabase price sync, release tagging, PR governance, agent delivery. |
| `AGENTS.md` / `CLAUDE.md` | Mandatory workflow rules for automated agents contributing to this repo. |
| `gitleaks.toml` | Secret-scanning configuration. |

## Flutter app

Entry point: [`monthy_budget_flutter/`](monthy_budget_flutter/).

Quick local setup:

```bash
cd monthy_budget_flutter
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test
```

Release builds require compile-time configuration passed via
`--dart-define-from-file`. See
[`monthy_budget_flutter/README.md`](monthy_budget_flutter/README.md) for the
full list of required keys and the recommended `env.local.json` workflow.

CI/CD, required GitHub secrets, and the release-notes workflow are documented
in [`monthy_budget_flutter/docs/ci-releases.md`](monthy_budget_flutter/docs/ci-releases.md).

## Grocery scrapers

The `scrapers/` package produces country-specific price bundles consumed by the
Flutter app and synced into Supabase.

```bash
cd scrapers
pip install -r requirements.txt
python run_scrapers.py --help
python -m pytest
```

The scrapers are driven on a schedule by
`.github/workflows/scrape-grocery-prices.yml` and the results are pushed into
Supabase via `.github/workflows/supabase-price-sync.yml`.

## Docs site

`docs/` is a static site (landing page, privacy policy, terms of use, Google
Play release guide) served via GitHub Pages. Assets are plain HTML/CSS/JS and
can be previewed locally by opening `docs/index.html` in a browser.

## Contributing (mandatory workflow)

This repository enforces an issue-driven delivery flow for every code change
(including agent-authored changes). The full rules live in
[`AGENTS.md`](AGENTS.md) and [`CLAUDE.md`](CLAUDE.md). Summary:

1. Every code change must map to a GitHub issue. Create one if it does not
   already exist.
2. Branch from `origin/main` and include the issue number in the branch name
   (e.g. `issue-123-short-description`).
3. Rebase on `origin/main` before pushing. Never push directly to `main`.
4. Commit messages must reference the issue (`#<issue-number>`) so the
   pipeline can link the PR.
5. PR body must include `Fixes #N` and a `## Release Notes` section, and must
   carry exactly one release label: `release:patch`, `release:minor`, or
   `release:major`.
6. CI runs quality gates, tests, and PR governance. On success the PR is
   auto-merged into `main` and a release tag is cut by the release workflow.

## License

See individual subproject files for license information.
