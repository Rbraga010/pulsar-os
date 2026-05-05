#!/usr/bin/env bash
# Configura MCP servers no Claude Code do cliente

install_mcp_servers() {
  if state_done "mcp"; then ok "MCP ja configurado"; return; fi
  step "[6/8] Configurando MCP servers no Claude Code"

  local cfg="${HOME}/.claude/config.json"
  mkdir -p "${HOME}/.claude"

  # Cria config minimo se nao existe
  if [[ ! -f "${cfg}" ]]; then
    echo '{"mcpServers":{}}' > "${cfg}"
  fi

  # shellcheck source=/dev/null
  source "${STATE_DIR}/postgres.env"

  # warroom MCP (local)
  local target="${PULSAR_OS_HOME:-$PWD}"
  jq --arg url "${DATABASE_URL}" \
     --arg cmd "node" \
     --arg arg "${target}/mcp-servers/warroom/dist/index.js" \
     '.mcpServers.warroom = {
        "command": $cmd,
        "args": [$arg],
        "env": {"DATABASE_URL": $url}
      }' "${cfg}" > "${cfg}.tmp" && mv "${cfg}.tmp" "${cfg}"
  ok "MCP warroom registrado"

  # telegram MCP (placeholder — tokens vem na 4b)
  jq '.mcpServers.telegram = {
        "command": "node",
        "args": ["'"${target}"'/mcp-servers/telegram/dist/index.js"],
        "env": {
          "TELEGRAM_BOT_PRIMARY_TOKEN": "AGUARDANDO_4B",
          "TELEGRAM_BOT_SECONDARY_TOKEN": "AGUARDANDO_4B"
        }
      }' "${cfg}" > "${cfg}.tmp" && mv "${cfg}.tmp" "${cfg}"
  ok "MCP telegram registrado (tokens placeholder — Iniciativa 4b preenche)"

  state_mark "mcp"
}
