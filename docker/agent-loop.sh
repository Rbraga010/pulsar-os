#!/bin/bash
# Clara · agent-loop dentro do container
# Adaptado de /root/scripts/agent-loop.sh (Pulse/Donna/Clara) · só clara aqui.
#
# Sistema:
#   - entrypoint.sh já validou login + .env + access.json
#   - tmux session "clara" roda este script
#   - claude --channels plugin:telegram@... conecta o bot Telegram
#   - while loop respawna se o claude cair (5s backoff)

set -uo pipefail

AGENT="clara"
LOG_FILE="${LOG_FILE:-/var/log/clara-tui.log}"
WORKDIR="${WORKSPACE_DIR:-/workspace}"

# Tools permitidas · matches o que clara.service do host usa
ALLOWED_TOOLS="Read Write Edit Glob Grep Bash(*) WebSearch WebFetch Agent mcp__plugin_telegram_telegram__*"

CHANNELS_FLAG="--channels plugin:telegram@claude-plugins-official"
ADD_DIRS=(--add-dir "$WORKDIR" --add-dir "$WORKDIR/cerebro")

export TELEGRAM_STATE_DIR="/root/.claude/channels/telegram-clara"

cd "$WORKDIR" || { echo "WORKDIR $WORKDIR ausente" >&2; exit 1; }

# Cria log se ausente
touch "$LOG_FILE" 2>/dev/null || LOG_FILE=/tmp/clara-tui.log
touch "$LOG_FILE"

while true; do
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf "\n==== %s starting claude (%s) ====\n" "$ts" "$AGENT" >> "$LOG_FILE"

  # script(1) embrulha o claude num PTY (TUI exige TTY)
  # --permission-mode acceptEdits resolve travamento em prompts de tool
  /usr/bin/script -qfc \
    "exec /usr/local/bin/claude --permission-mode acceptEdits $CHANNELS_FLAG ${ADD_DIRS[*]} --allowedTools '$ALLOWED_TOOLS'" \
    "$LOG_FILE"
  rc=$?

  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf "\n==== %s claude (%s) exited rc=%d, respawn in 5s ====\n" "$ts" "$AGENT" "$rc" >> "$LOG_FILE"
  sleep 5
done
