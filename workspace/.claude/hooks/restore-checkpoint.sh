#!/bin/bash
# Blindagem de memória · restaura checkpoint (hook SessionStart matcher resume|compact).
# Injeta o último checkpoint como contexto adicional quando a Clara acorda de restart ou
# compactação, garantindo que ela retome de onde parou. SEMPRE sai 0.
set +e
DIR="${CLAUDE_PROJECT_DIR:-/workspace}"
CP="$DIR/cerebro/memory/current-checkpoint.md"
python3 - "$CP" <<'PY'
import json, sys, os
p = sys.argv[1]
ctx = open(p).read() if os.path.exists(p) else "Sem checkpoint anterior. LEIA cerebro/memory/ antes de responder."
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ctx}}))
PY
exit 0
