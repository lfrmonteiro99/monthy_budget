#!/usr/bin/env bash
# Validates that all ARB localization files contain the same set of
# translatable keys.  Metadata keys (@@locale, @-prefixed) are excluded.
set -euo pipefail

L10N_DIR="${1:-lib/l10n}"

if [ ! -d "$L10N_DIR" ]; then
  echo "ERROR: l10n directory not found: $L10N_DIR"
  exit 1
fi

ARB_FILES=("$L10N_DIR"/app_*.arb)

if [ "${#ARB_FILES[@]}" -eq 0 ]; then
  echo "ERROR: no ARB files found in $L10N_DIR"
  exit 1
fi

echo "Found ${#ARB_FILES[@]} ARB file(s):"
printf '  %s\n' "${ARB_FILES[@]}"

# Extract translatable keys (exclude @@locale and @-prefixed metadata keys)
extract_keys() {
  python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
keys = sorted(k for k in data if not k.startswith('@'))
print('\n'.join(keys))
" "$1"
}

REFERENCE_FILE="${ARB_FILES[0]}"
REFERENCE_KEYS="$(extract_keys "$REFERENCE_FILE")"
REFERENCE_NAME="$(basename "$REFERENCE_FILE")"

ERRORS=0

for ARB in "${ARB_FILES[@]}"; do
  NAME="$(basename "$ARB")"
  KEYS="$(extract_keys "$ARB")"

  MISSING="$(comm -23 <(echo "$REFERENCE_KEYS") <(echo "$KEYS"))"
  EXTRA="$(comm -13 <(echo "$REFERENCE_KEYS") <(echo "$KEYS"))"

  if [ -n "$MISSING" ]; then
    echo ""
    echo "ERROR: $NAME is missing keys present in $REFERENCE_NAME:"
    echo "$MISSING" | sed 's/^/  - /'
    ERRORS=1
  fi

  if [ -n "$EXTRA" ]; then
    echo ""
    echo "ERROR: $NAME has keys not present in $REFERENCE_NAME:"
    echo "$EXTRA" | sed 's/^/  - /'
    ERRORS=1
  fi
done

if [ "$ERRORS" -eq 0 ]; then
  echo ""
  echo "All ARB files have consistent keys ($(echo "$REFERENCE_KEYS" | wc -l) keys each)."
  exit 0
else
  echo ""
  echo "ARB key validation FAILED."
  exit 1
fi
