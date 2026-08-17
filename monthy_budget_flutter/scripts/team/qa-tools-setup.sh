#!/bin/bash
# qa-tools-setup.sh — make the browser toolkit ready to run. Idempotent, so every
# role that needs a browser can just call it.
#
# The toolkit lives in its own npm project OUTSIDE the repo: the tester scripts
# must run from a directory where `import 'playwright'` resolves, and putting
# node_modules inside a git worktree means every agent worktree either duplicates
# it or trips over it.
#
# Two separate installs are required and BOTH matter:
#   1. the npm package
#   2. the browser binary — playwright pins an exact build per version, so a
#      chromium left in the cache by a different playwright version does NOT
#      count. Getting this wrong fails at launch() with "Executable doesn't
#      exist", which reads like a code bug and is not one.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
ROLE="qa-tools"

QA_TOOLS="${TEAM_QA_TOOLS:-$HOME/Documentos/monthy-budget-qa-tools}"
PW_VERSION="${TEAM_PLAYWRIGHT_VERSION:-1.58.2}"

mkdir -p "$QA_TOOLS"

if [ ! -f "$QA_TOOLS/package.json" ]; then
  cat > "$QA_TOOLS/package.json" <<JSON
{
  "name": "monthy-budget-qa-tools",
  "private": true,
  "type": "module",
  "dependencies": { "playwright": "$PW_VERSION" }
}
JSON
fi

if [ ! -d "$QA_TOOLS/node_modules/playwright" ]; then
  log "a instalar o playwright em $QA_TOOLS..."
  ( cd "$QA_TOOLS" && npm install --no-audit --no-fund ) \
    || { log "ERRO: npm install falhou"; exit 1; }
fi

# Always refresh the driver from git: the repository is the single source of
# truth, and a stale copy here would silently test with an old toolkit.
cp -f "$SCRIPT_DIR/qa/flutter_driver.mjs" "$SCRIPT_DIR/qa/probe.mjs" "$QA_TOOLS/" \
  || { log "ERRO: não copiei o toolkit"; exit 1; }

# Ask playwright itself whether its browser is present, rather than guessing at
# cache paths — the build number is an internal detail that changes per release.
if ! ( cd "$QA_TOOLS" && node -e "
import('playwright').then(async (pw) => {
  const fs = await import('node:fs');
  const p = pw.chromium.executablePath();
  process.exit(fs.existsSync(p) ? 0 : 1);
}).catch(() => process.exit(1));
" ) 2>/dev/null; then
  log "a descarregar o chromium correspondente ao playwright $PW_VERSION..."
  ( cd "$QA_TOOLS" && npx --yes playwright install chromium ) \
    || { log "ERRO: playwright install chromium falhou"; exit 1; }
fi

log "toolkit pronto em $QA_TOOLS"
