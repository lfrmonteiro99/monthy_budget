#!/bin/bash
# qa-describe-image.sh — turn a screenshot into text, for agents whose model cannot
# see.
#
# WHY THIS EXISTS. Several roles are told to look at the evidence screenshots: it is
# how a tester judges layout and how a curator checks a finding's proof. Claude does
# that natively. The fallback model does not accept image input at all, and fails
# hard — `API Error: 400 this model does not support image input` kills the entire
# run with no verdict (observed on curator-1238).
#
# The answer is not to blind the agent. It is to SPLIT THE REQUEST: a vision model
# describes the image, and the reasoning model works from that description. The
# reasoning model keeps doing what it is good at, and the picture still reaches it.
#
# gemma4:31b was picked by testing the cloud catalogue against a real screenshot from
# a critic run: it reported the screen, the field values, AND the validation error
# state (red outline plus "Introduza um valor válido"). qwen3.5:397b also accepts
# images; glm-5.2 and deepseek-v4-flash do not.
#
# Usage: qa-describe-image.sh <image> [pergunta]
set -uo pipefail

IMG="${1:?caminho da imagem obrigatorio}"
QUESTION="${2:-Descreve este screenshot de uma app móvel com precisão: que ecrã é, que valores estão visíveis, e qualquer defeito visual (texto cortado, elementos sobrepostos, desalinhamento, contraste fraco).}"

VISION_MODEL="${TEAM_VISION_MODEL:-gemma4:31b}"
OLLAMA_URL="${TEAM_OLLAMA_URL:-https://ollama.com}"

[ -f "$IMG" ] || { echo "ERRO: imagem não existe: $IMG" >&2; exit 1; }

# Same credential resolution as run-agent.sh.
if [ -z "${OLLAMA_API_KEY:-}" ]; then
  for src in "$HOME/.config/monthy-budget-team/env" "$HOME/Documentos/companion-chat/.env"; do
    if [ -f "$src" ]; then
      key=$(grep -E '^(OLLAMA_API_KEY|MANAGED_CHAT_API_KEY)=' "$src" 2>/dev/null | head -1 | cut -d= -f2-)
      if [ -n "$key" ]; then export OLLAMA_API_KEY="$key"; break; fi
    fi
  done
fi
[ -n "${OLLAMA_API_KEY:-}" ] || { echo "ERRO: sem OLLAMA_API_KEY" >&2; exit 1; }

# The payload goes through a FILE, never the command line: a base64 screenshot is
# ~140KB and `curl -d "$B64"` dies with "Argument list too long".
PAYLOAD=$(mktemp /tmp/qa-vision.XXXXXX.json)
trap 'rm -f "$PAYLOAD"' EXIT

python3 - "$IMG" "$QUESTION" "$VISION_MODEL" "$PAYLOAD" <<'PY'
import base64, json, sys
img, question, model, out = sys.argv[1:5]
with open(img, "rb") as fh:
    b64 = base64.b64encode(fh.read()).decode()
json.dump({"model": model, "prompt": question, "images": [b64], "stream": False},
          open(out, "w"))
PY

RESP=$(curl -s --max-time "${TEAM_VISION_TIMEOUT:-240}" \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -H "Content-Type: application/json" \
  "$OLLAMA_URL/api/generate" -d @"$PAYLOAD" 2>/dev/null)

printf '%s' "$RESP" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("ERRO: resposta ilegível do modelo de visão", file=sys.stderr); sys.exit(1)
if d.get("response"):
    print(d["response"])
else:
    print("ERRO: " + str(d.get("error", "sem resposta")), file=sys.stderr); sys.exit(1)
'
