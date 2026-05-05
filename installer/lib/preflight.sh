#!/usr/bin/env bash
# Pre-flight checks — aborta cedo se VPS nao atende minimo

preflight_checks() {
  step "[0/8] Pre-flight (idempotente)"

  # 1. root ou sudo
  if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
    err "Precisa rodar como root ou com sudo sem senha. Atual: $(whoami)"
  fi
  ok "root/sudo OK"

  # 2. Ubuntu/Debian 22+
  if [[ ! -f /etc/os-release ]]; then err "Nao consegui ler /etc/os-release"; fi
  # shellcheck source=/dev/null
  source /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ok "OS: ${PRETTY_NAME}";;
    *) warn "OS '${ID:-?}' nao testado (esperado ubuntu/debian). Continuando por sua conta.";;
  esac
  if [[ "${ID:-}" == "ubuntu" ]]; then
    local major; major=$(echo "${VERSION_ID:-0}" | cut -d. -f1)
    [[ "${major}" -ge 22 ]] || err "Ubuntu >=22.04 requerido. Voce: ${VERSION_ID:-?}"
  fi

  # 3. 5GB livres em /
  local free_kb; free_kb=$(df -k / | awk 'NR==2{print $4}')
  local free_gb=$(( free_kb / 1024 / 1024 ))
  [[ "${free_gb}" -ge 5 ]] || err "Disco: ${free_gb}GB livres. Minimo 5GB."
  ok "Disco: ${free_gb}GB livres"

  # 4. Portas livres (3000 web, 5432 postgres, 8765 mcp)
  for port in 3000 5432 8765; do
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${port}\$"; then
      warn "Porta ${port} ocupada — pode dar conflito (ignorando se for o proprio Pulsar OS rodando)"
    fi
  done
  ok "Portas checadas"

  # 5. Conexao github
  if ! curl -sf -o /dev/null --max-time 5 https://github.com; then
    err "Sem conexao com github.com — checa internet/firewall"
  fi
  ok "github.com alcancavel"

  # 6. Claude Code
  if ! command -v claude >/dev/null 2>&1; then
    err "Claude Code nao instalado. Veja https://docs.anthropic.com/claude-code"
  fi
  ok "Claude Code: $(claude --version 2>/dev/null | head -1 || echo 'instalado')"

  # 7. Dominio aponta pra VPS (nao-fatal — warn so)
  if [[ -n "${PULSAR_TENANT_DOMAIN:-}" && -n "${PULSAR_VPS_IP:-}" ]]; then
    local resolved; resolved=$(dig +short "${PULSAR_TENANT_DOMAIN}" 2>/dev/null | tail -1)
    if [[ "${resolved}" == "${PULSAR_VPS_IP}" ]]; then
      ok "DNS ${PULSAR_TENANT_DOMAIN} -> ${PULSAR_VPS_IP}"
    else
      warn "DNS ${PULSAR_TENANT_DOMAIN} -> '${resolved}' (esperado ${PULSAR_VPS_IP}) — propaga depois"
    fi
  fi
}
