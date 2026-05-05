#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — Bots Wizard (Iniciativa 4b)
#  Orienta Founder a criar 2 bots Telegram (@BotFather), valida tokens,
#  persiste em tenant/.env.local + ~/.claude/config.json (MCP telegram),
#  dispara smoke first-message.
#
#  Uso:  bash wizard.sh
#  Idempotente: tokens ja validados sao reutilizados.
# ══════════════════════════════════════════════════════════════════════════

set -euo pipefail

WIZARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "${WIZARD_DIR}/.." && pwd)"
PULSAR_OS_HOME="${PULSAR_OS_HOME:-$(cd "${INSTALLER_DIR}/.." && pwd)}"
TENANT_DIR="${PULSAR_OS_HOME}/tenant"
ENV_FILE="${TENANT_DIR}/.env.local"
AGENTS_CFG="${TENANT_DIR}/agents-config.json"
CLAUDE_CFG="${HOME}/.claude/config.json"
INSTRUCAO="${WIZARD_DIR}/clip-instrucao.md"
SMOKE_SCRIPT="${INSTALLER_DIR}/smoke/first-message.sh"

mkdir -p "${TENANT_DIR}"
touch "${ENV_FILE}"
chmod 0600 "${ENV_FILE}"

# Cores simples (sem dependencia)
c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_red=$'\033[31m'; c_yellow=$'\033[33m'; c_off=$'\033[0m'
say()   { printf "%s%s%s\n" "$c_bold" "$*" "$c_off"; }
muted() { printf "%s%s%s\n" "$c_dim" "$*" "$c_off"; }
ok()    { printf "%s✅ %s%s\n" "$c_green" "$*" "$c_off"; }
err()   { printf "%s❌ %s%s\n" "$c_red" "$*" "$c_off"; }
warn()  { printf "%s⚠  %s%s\n" "$c_yellow" "$*" "$c_off"; }

# ----- helpers ------------------------------------------------------------

show_instrucao() {
  if command -v less >/dev/null 2>&1; then
    less -R "${INSTRUCAO}" || cat "${INSTRUCAO}"
  else
    cat "${INSTRUCAO}"
  fi
}

read_secret() {
  # input mascarado (sem echo). $1 = prompt
  local prompt="$1" var
  printf "%s" "${prompt}"
  read -r -s var
  printf "\n"
  printf "%s" "${var}"
}

env_get() {
  # le var de tenant/.env.local
  local key="$1"
  [ -f "${ENV_FILE}" ] || { printf ""; return; }
  grep -E "^${key}=" "${ENV_FILE}" | tail -1 | cut -d= -f2- | sed 's/^"//;s/"$//'
}

env_set() {
  local key="$1" val="$2"
  if grep -qE "^${key}=" "${ENV_FILE}" 2>/dev/null; then
    # remove linha antiga (portavel mac/linux)
    grep -vE "^${key}=" "${ENV_FILE}" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "${ENV_FILE}"
  fi
  printf '%s="%s"\n' "${key}" "${val}" >> "${ENV_FILE}"
  chmod 0600 "${ENV_FILE}"
}

validate_token() {
  # GET /getMe — ecoa username se ok, retorna 1 se invalido
  local token="$1" resp username ok_field
  resp="$(curl -fsS --max-time 10 "https://api.telegram.org/bot${token}/getMe" 2>/dev/null || true)"
  if [ -z "${resp}" ]; then
    return 1
  fi
  ok_field="$(printf "%s" "${resp}" | jq -r '.ok' 2>/dev/null || echo false)"
  if [ "${ok_field}" != "true" ]; then
    return 1
  fi
  username="$(printf "%s" "${resp}" | jq -r '.result.username')"
  printf "%s" "${username}"
}

prompt_token_loop() {
  # $1 = role label (Pulse|Donna), $2 = env key
  local role="$1" key="$2" existing username token
  existing="$(env_get "${key}")"
  if [ -n "${existing}" ]; then
    username="$(validate_token "${existing}" || true)"
    if [ -n "${username}" ]; then
      ok "${role} ja configurado: @${username}"
      return 0
    else
      warn "${role} token salvo invalidou (revogado?). Vou pedir de novo."
    fi
  fi

  while true; do
    say ""
    say "—— ${role} ——"
    while true; do
      printf "Voce ja criou o bot %s no @BotFather? [s/n]: " "${role}"
      read -r ans
      case "${ans:-}" in
        s|S|sim|y|Y) break ;;
        n|N|nao|no) muted "Sem stress. Reabrindo o tutorial."; show_instrucao ;;
        *) warn "Responde s ou n." ;;
      esac
    done
    token="$(read_secret "Cole o token (input oculto): ")"
    if [ -z "${token}" ]; then
      err "Token vazio. Tenta de novo."
      continue
    fi
    username="$(validate_token "${token}" || true)"
    if [ -z "${username}" ]; then
      err "Token nao valida em api.telegram.org/getMe. Confere se copiou inteiro."
      continue
    fi
    env_set "${key}" "${token}"
    env_set "${key}_USERNAME" "${username}"
    ok "${role}: @${username}"
    return 0
  done
}

merge_mcp_telegram() {
  # Merge nao-destrutivo em ~/.claude/config.json — adiciona/atualiza envs do MCP telegram
  local pulse_token donna_token
  pulse_token="$(env_get TELEGRAM_PULSE_BOT_TOKEN)"
  donna_token="$(env_get TELEGRAM_DONNA_BOT_TOKEN)"

  mkdir -p "$(dirname "${CLAUDE_CFG}")"
  if [ ! -f "${CLAUDE_CFG}" ]; then
    echo '{}' > "${CLAUDE_CFG}"
  fi

  local tmp; tmp="$(mktemp)"
  jq \
    --arg pt "${pulse_token}" \
    --arg dt "${donna_token}" \
    '
    .mcpServers = (.mcpServers // {})
    | .mcpServers["plugin:telegram:telegram"] = (
        (.mcpServers["plugin:telegram:telegram"] // {})
        | .env = (.env // {})
        | .env.TELEGRAM_PULSE_BOT_TOKEN = $pt
        | .env.TELEGRAM_DONNA_BOT_TOKEN = $dt
      )
    ' "${CLAUDE_CFG}" > "${tmp}" && mv "${tmp}" "${CLAUDE_CFG}"
  ok "MCP telegram atualizado em ~/.claude/config.json"
}

# ----- fluxo principal ----------------------------------------------------

clear || true
say "═══════════════════════════════════════════════"
say " Pulsar OS — Wizard de Bots Telegram (passo 4b)"
say "═══════════════════════════════════════════════"
muted "Voce vai criar 2 bots no @BotFather. Eu valido cada token, salvo seguro, e disparo a primeira mensagem do Pulse."
say ""

if [ ! -f "${INSTRUCAO}" ]; then
  err "Tutorial nao encontrado em ${INSTRUCAO}"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  err "jq nao instalado. Rode 'apt install -y jq' antes."
  exit 1
fi

say "Vou abrir o tutorial passo-a-passo. Quando terminar, volta aqui."
muted "(aperte 'q' pra sair do tutorial e voltar)"
sleep 2
show_instrucao

say ""
prompt_token_loop "Pulse" TELEGRAM_PULSE_BOT_TOKEN
prompt_token_loop "Donna" TELEGRAM_DONNA_BOT_TOKEN

say ""
say "—— MCP ——"
merge_mcp_telegram

say ""
say "—— Smoke ——"
while true; do
  printf "Posso disparar a primeira mensagem do Pulse no seu Telegram agora? [s/n]: "
  read -r go
  case "${go:-}" in
    s|S|sim|y|Y)
      if [ -x "${SMOKE_SCRIPT}" ]; then
        bash "${SMOKE_SCRIPT}"
      else
        bash "${SMOKE_SCRIPT}"
      fi
      break
      ;;
    n|N|nao|no)
      muted "Beleza. Quando quiser: pulsar-os smoke (ou bash installer/smoke/first-message.sh)"
      break
      ;;
    *) warn "Responde s ou n." ;;
  esac
done

say ""
ok "Wizard concluido. Tokens em ${ENV_FILE} (perm 0600)."
say ""
