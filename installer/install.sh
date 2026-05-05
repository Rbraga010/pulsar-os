#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — Installer (Iniciativa 4a — infra base)
#  Postgres + repo + Vercel + MCP — sem Telegram (4b cuida disso)
#
#  Uso: bash install.sh
#  Pre-requisitos:
#    - VPS Ubuntu/Debian 22+ root SSH
#    - Internet
#    - Claude Code instalado (which claude)
#    - ~5GB livres
#    - Founder Vercel email correto em maos
# ══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Resolve diretorio do script (idempotente, funciona com bash install.sh ou ./install.sh)
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export INSTALLER_DIR

# Estado em /tenant/.install-state pra idempotencia entre re-runs
STATE_DIR="${PULSAR_OS_HOME:-$PWD}/tenant"
STATE_FILE="${STATE_DIR}/.install-state"
mkdir -p "${STATE_DIR}"
touch "${STATE_FILE}"
export STATE_DIR STATE_FILE

# Carrega libs
# shellcheck source=lib/log.sh
source "${INSTALLER_DIR}/lib/log.sh"
# shellcheck source=lib/prompt.sh
source "${INSTALLER_DIR}/lib/prompt.sh"
# shellcheck source=lib/state.sh
source "${INSTALLER_DIR}/lib/state.sh"
# shellcheck source=lib/preflight.sh
source "${INSTALLER_DIR}/lib/preflight.sh"
# shellcheck source=lib/deps.sh
source "${INSTALLER_DIR}/lib/deps.sh"
# shellcheck source=lib/repo.sh
source "${INSTALLER_DIR}/lib/repo.sh"
# shellcheck source=lib/postgres.sh
source "${INSTALLER_DIR}/lib/postgres.sh"
# shellcheck source=lib/vercel.sh
source "${INSTALLER_DIR}/lib/vercel.sh"
# shellcheck source=lib/mcp.sh
source "${INSTALLER_DIR}/lib/mcp.sh"
# shellcheck source=lib/tenant.sh
source "${INSTALLER_DIR}/lib/tenant.sh"

print_header() {
  cat <<'BANNER'

  ██████╗ ██╗   ██╗██╗     ███████╗ █████╗ ██████╗      ██████╗ ███████╗
  ██╔══██╗██║   ██║██║     ██╔════╝██╔══██╗██╔══██╗    ██╔═══██╗██╔════╝
  ██████╔╝██║   ██║██║     ███████╗███████║██████╔╝    ██║   ██║███████╗
  ██╔═══╝ ██║   ██║██║     ╚════██║██╔══██║██╔══██╗    ██║   ██║╚════██║
  ██║     ╚██████╔╝███████╗███████║██║  ██║██║  ██║    ╚██████╔╝███████║
  ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝

       Installer 4a — infra base (Postgres + repo + Vercel + MCP)
       Telegram + smoke E2E ficam pra etapa 4b.

BANNER
}

prompt_tenant_basics() {
  if state_done "tenant_basics"; then ok "Tenant basics ja coletados"; return; fi
  step "[1/8] Coletando dados essenciais do tenant"
  ask "Slug do tenant (a-z, 0-9, hifen apenas)" "" PULSAR_TENANT_SLUG
  ask "Nome do tenant (display name)" "" PULSAR_TENANT_NAME
  ask "Dominio principal (ex: empresa.com.br)" "" PULSAR_TENANT_DOMAIN
  ask "IP da VPS (detectado abaixo, ENTER pra confirmar)" "$(curl -sf https://api.ipify.org || echo '')" PULSAR_VPS_IP
  ask "Email da conta Vercel do founder (CRITICO — quebra deploy se errado)" "" PULSAR_VERCEL_EMAIL
  warn "AVISO: commits pra Vercel team usarao email '${PULSAR_VERCEL_EMAIL}'. Email errado = deploy ERROR."
  cat > "${STATE_DIR}/tenant-basics.env" <<EOF
PULSAR_TENANT_SLUG="${PULSAR_TENANT_SLUG}"
PULSAR_TENANT_NAME="${PULSAR_TENANT_NAME}"
PULSAR_TENANT_DOMAIN="${PULSAR_TENANT_DOMAIN}"
PULSAR_VPS_IP="${PULSAR_VPS_IP}"
PULSAR_VERCEL_EMAIL="${PULSAR_VERCEL_EMAIL}"
EOF
  state_mark "tenant_basics"
}

print_handoff_to_4b() {
  cat <<EOF

  ${GREEN}${BOLD}Infra 4a OK.${NC}

  Proximo passo (Iniciativa 4b — bots + smoke):
    1. Crie 2 bots no @BotFather (CEO + Secretaria), copie tokens
    2. Rode: ${BLUE}bash installer/wizard-4b.sh${NC} (a ser entregue na 4b)
    3. Pulse vai capturar chat_id e iniciar entrevista de onboarding

  Estado salvo em: ${STATE_DIR}/
  Logs em:         ${STATE_DIR}/install.log

EOF
}

main() {
  print_header
  preflight_checks
  prompt_tenant_basics
  install_dependencies
  clone_repo
  provision_postgres
  setup_vercel_project
  install_mcp_servers
  write_tenant_skeleton
  print_handoff_to_4b
}

main "$@" 2>&1 | tee -a "${STATE_DIR}/install.log"
