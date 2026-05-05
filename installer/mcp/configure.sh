#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — MCP configure standalone
#  Adiciona warroom + telegram MCP servers em ~/.claude/config.json
#  SEM substituir entradas existentes (merge via jq).
#
#  Uso: bash mcp/configure.sh
# ══════════════════════════════════════════════════════════════════════════

set -euo pipefail

INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/log.sh
source "${INSTALLER_DIR}/lib/log.sh"

CFG="${HOME}/.claude/config.json"
PULSAR_OS_HOME="${PULSAR_OS_HOME:-$PWD}"

mkdir -p "${HOME}/.claude"
[[ -f "${CFG}" ]] || echo '{"mcpServers":{}}' > "${CFG}"

# Backup antes de mexer
cp "${CFG}" "${CFG}.bak.$(date +%s)"

DB_URL="${DATABASE_URL:-}"
if [[ -z "${DB_URL}" && -f "${PWD}/tenant/postgres.env" ]]; then
  # shellcheck source=/dev/null
  source "${PWD}/tenant/postgres.env"
  DB_URL="${DATABASE_URL}"
fi
[[ -n "${DB_URL}" ]] || err "DATABASE_URL nao definida — set env ou rode install.sh primeiro"

# Merge warroom (preserva outros mcpServers existentes)
jq --arg url "${DB_URL}" \
   --arg path "${PULSAR_OS_HOME}/mcp-servers/warroom/dist/index.js" \
   '.mcpServers = (.mcpServers // {}) | .mcpServers.warroom = {
      "command": "node",
      "args": [$path],
      "env": {"DATABASE_URL": $url}
    }' "${CFG}" > "${CFG}.tmp" && mv "${CFG}.tmp" "${CFG}"
ok "MCP warroom merged"

# Merge telegram (placeholder tokens — Iniciativa 4b preenche)
jq --arg path "${PULSAR_OS_HOME}/mcp-servers/telegram/dist/index.js" \
   '.mcpServers.telegram = (.mcpServers.telegram // {
      "command": "node",
      "args": [$path],
      "env": {
        "TELEGRAM_BOT_PRIMARY_TOKEN": "AGUARDANDO_4B",
        "TELEGRAM_BOT_SECONDARY_TOKEN": "AGUARDANDO_4B"
      }
    })' "${CFG}" > "${CFG}.tmp" && mv "${CFG}.tmp" "${CFG}"
ok "MCP telegram merged (placeholder)"

step "Reinicie o Claude Code pra carregar os MCP servers"
