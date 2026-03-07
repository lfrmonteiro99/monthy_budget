#!/usr/bin/env bash
set -euo pipefail

labels=(
  "ui:UX/UI work:#1f6feb"
  "backend:Backend/API/database:#0052cc"
  "performance:Performance improvements:#5319e7"
  "testing:Tests and QA:#fbca04"
  "chore:Maintenance tasks:#c2e0c6"
  "release:patch:Patch release:#0e8a16"
  "release:minor:Minor release:#1d76db"
  "release:major:Major release:#b60205"
  "type:bug:Bug fix work:#d73a4a"
  "type:feature:Feature work:#a2eeef"
)

for item in "${labels[@]}"; do
  IFS=':' read -r name desc color <<< "$item"
  if gh label list --limit 200 | awk '{print $1}' | grep -qx "$name"; then
    echo "Label exists: $name"
  else
    gh label create "$name" --description "$desc" --color "$color"
    echo "Created label: $name"
  fi
done
