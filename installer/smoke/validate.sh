#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — Smoke validate (Iniciativa 4b)
#  Checklist pos-smoke. Roda quando quiser.
# ══════════════════════════════════════════════════════════════════════════

set -uo pipefail

SMOKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "${SMOKE_DIR}/.." && pwd)"
PULSAR_OS_HOME="${PULSAR_OS_HOME:-$(cd "${INSTALLER_DIR}/.." && pwd)}"
TENANT_DIR="${PULSAR_OS_HOME}/tenant"
ENV_FILE="${TENANT_DIR}/.env.local"
AGENTS_CFG="${TENANT_DIR}/agents-config.json"
CLAUDE_CFG="${HOME}/.claude/config.json"
README="${INSTALLER_DIR}/bots/README-founder.md"

c_green=$'\033[32m'; c_red=$'\033[31m'; c_yellow=$'\033[33m'; c_off=$'\033[0m'
pass() { printf "%s[PASS]%s %s\n" "$c_green" "$c_off" "$*"; PASSED=$((PASSED+1)); }
fail() { printf "%s[FAIL]%s %s\n" "$c_red"   "$c_off" "$*"; FAILED=$((FAILED+1)); FAILURES+=("$*"); }
warn() { printf "%s[WARN]%s %s\n" "$c_yellow" "$c_off" "$*"; }

PASSED=0; FAILED=0; FAILURES=()

echo "═══ Pulsar OS — Smoke Validate ═══"
echo ""

# 1. tokens validos via getMe
PULSE_TOKEN="$(grep -E '^TELEGRAM_PULSE_BOT_TOKEN=' "${ENV_FILE}" 2>/dev/null | tail -1 | cut -d= -f2- | sed 's/^"//;s/"$//' || echo '')"
DONNA_TOKEN="$(grep -E '^TELEGRAM_DONNA_BOT_TOKEN=' "${ENV_FILE}" 2>/dev/null | tail -1 | cut -d= -f2- | sed 's/^"//;s/"$//' || echo '')"

if [ -n "${PULSE_TOKEN}" ] && [ "$(curl -fsS --max-time 8 "https://api.telegram.org/bot${PULSE_TOKEN}/getMe" 2>/dev/null | jq -r '.ok' 2>/dev/null)" = "true" ]; then
  pass "Pulse token valido (getMe ok)"
else
  fail "Pulse token invalido ou ausente"
fi

if [ -n "${DONNA_TOKEN}" ] && [ "$(curl -fsS --max-time 8 "https://api.telegram.org/bot${DONNA_TOKEN}/getMe" 2>/dev/null | jq -r '.ok' 2>/dev/null)" = "true" ]; then
  pass "Donna token valido (getMe ok)"
else
  fail "Donna token invalido ou ausente"
fi

# 2. chat_id capturado
CHAT_ID=""
if [ -f "${AGENTS_CFG}" ]; then
  CHAT_ID="$(jq -r '.tenant.contacts.founder_chat_id // ""' "${AGENTS_CFG}" 2>/dev/null || echo '')"
fi
if [ -n "${CHAT_ID}" ] && [ "${CHAT_ID}" != "null" ]; then
  pass "founder_chat_id em agents-config.json: ${CHAT_ID}"
else
  fail "founder_chat_id ausente — rode bash installer/smoke/first-message.sh"
fi

# 3. permissoes do .env.local
if [ -f "${ENV_FILE}" ]; then
  PERM="$(stat -c '%a' "${ENV_FILE}" 2>/dev/null || stat -f '%Lp' "${ENV_FILE}" 2>/dev/null || echo '?')"
  if [ "${PERM}" = "600" ]; then
    pass ".env.local com permissao 0600"
  else
    warn ".env.local com permissao ${PERM} (esperado 600)"
  fi
else
  fail ".env.local ausente"
fi

# 4. War Room healthcheck (local)
if curl -fsS --max-time 5 "http://localhost:3000" >/dev/null 2>&1 || \
   curl -fsS --max-time 5 "http://localhost:3000/api/health" >/dev/null 2>&1; then
  pass "War Room responde em localhost:3000"
else
  warn "War Room nao responde em localhost:3000 (ok se Vercel-only)"
fi

# 5. MCP servers em ~/.claude/config.json
if [ -f "${CLAUDE_CFG}" ]; then
  HAS_WARROOM="$(jq -r '.mcpServers["warroom"] // .mcpServers["mcp__warroom"] // empty' "${CLAUDE_CFG}" 2>/dev/null)"
  HAS_TG="$(jq -r '.mcpServers["plugin:telegram:telegram"] // empty' "${CLAUDE_CFG}" 2>/dev/null)"
  if [ -n "${HAS_WARROOM}" ]; then pass "MCP warroom em ~/.claude/config.json"; else fail "MCP warroom ausente"; fi
  if [ -n "${HAS_TG}" ];      then pass "MCP telegram em ~/.claude/config.json"; else fail "MCP telegram ausente"; fi
else
  fail "~/.claude/config.json nao existe"
fi

# 6. Pulse acionado (agent_logs no Postgres) — best-effort
if command -v psql >/dev/null 2>&1; then
  DB_URL="${DATABASE_URL:-$(grep -E '^DATABASE_URL=' /tenant/.env.local 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")}"
  if [ -z "${DB_URL}" ]; then
    warn "DATABASE_URL nao definido. Configure em /tenant/.env.local. Pulando check agent_logs."
    DB_URL=""
  fi
  COUNT="$(psql "${DB_URL}" -tAc "SELECT COUNT(*) FROM agent_logs WHERE agent_slug='pulseh';" 2>/dev/null || echo '?')"
  if [ "${COUNT}" != "?" ] && [ "${COUNT}" -gt 0 ] 2>/dev/null; then
    pass "agent_logs registra Pulse (${COUNT} entradas)"
  else
    warn "agent_logs vazio ou inacessivel (ok se ainda nao houve interacao)"
  fi
else
  warn "psql nao instalado — pulando check agent_logs"
fi

# ----- resumo --------------------------------------------------------------
echo ""
echo "═══ Resumo ═══"
echo "PASS: ${PASSED} | FAIL: ${FAILED}"

if [ "${FAILED}" -gt 0 ]; then
  echo ""
  echo "Falhas:"
  for f in "${FAILURES[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Troubleshooting: ${README}"
  exit 1
fi

echo ""
echo "Smoke validate OK. Pulsar OS pronto pra Iniciativa 3 (onboarding ritual)."
exit 0
