#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — Vercel setup wizard standalone
#  Pode ser rodado solo (apos install.sh principal) pra reconfigurar Vercel
#  sem refazer Postgres etc.
#
#  Uso: bash vercel/setup.sh
# ══════════════════════════════════════════════════════════════════════════

set -euo pipefail

INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/log.sh
source "${INSTALLER_DIR}/lib/log.sh"
# shellcheck source=../lib/prompt.sh
source "${INSTALLER_DIR}/lib/prompt.sh"

step "Vercel setup standalone"

# 1. Login
if ! vercel whoami >/dev/null 2>&1; then
  vercel login || err "vercel login falhou"
fi
ok "Logado como $(vercel whoami | tail -1)"

# 2. Founder email warning
ask "Email da conta Vercel deste tenant" "" VC_EMAIL
warn "Toda commit pra esse projeto vai precisar 'git config user.email = ${VC_EMAIL}'"
warn "Se o email do commit nao casar com a conta Vercel team, deploy retorna ERROR."

# 3. Link
if [[ ! -f .vercel/project.json ]]; then
  ask "Slug do projeto Vercel" "pulsar-os" VC_SLUG
  vercel link --yes --project "${VC_SLUG}"
fi
ok "Projeto linkado: $(jq -r '.projectId' .vercel/project.json 2>/dev/null || echo '?')"

# 4. Env vars (interativo)
add_env() {
  local key="$1"
  local val
  ask "Valor para ${key} (ENTER pra pular)" "" val
  if [[ -n "${val}" ]]; then
    echo "${val}" | vercel env add "${key}" production 2>/dev/null \
      || (vercel env rm "${key}" production --yes 2>/dev/null; echo "${val}" | vercel env add "${key}" production)
    ok "${key} definido"
  fi
}

step "Adicionando env vars (ENTER pra pular cada)"
add_env "DATABASE_URL"
add_env "PULSAR_TENANT_SLUG"
add_env "PULSAR_TENANT_NAME"
add_env "PULSAR_TENANT_DOMAIN"
add_env "MCP_WARROOM_URL"

# 5. Validacao via deploy
step "Disparando deploy de validacao"
LOG=$(mktemp)
if vercel deploy --prod --yes 2>&1 | tee "${LOG}" | grep -qE "ERROR|❌|Error:"; then
  err "Deploy retornou ERROR — checa email do commit autor x conta Vercel. Log: ${LOG}"
fi
ok "Deploy OK"
