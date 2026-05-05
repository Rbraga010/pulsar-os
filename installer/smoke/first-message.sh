#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════
#  Pulsar OS — Smoke: first message (Iniciativa 4b)
#  Captura chat_id do Founder (via /start) e dispara a primeira mensagem
#  do Pulse (welcome-script.md, msg 1) no Telegram.
#
#  Uso: bash first-message.sh
# ══════════════════════════════════════════════════════════════════════════

set -euo pipefail

SMOKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "${SMOKE_DIR}/.." && pwd)"
PULSAR_OS_HOME="${PULSAR_OS_HOME:-$(cd "${INSTALLER_DIR}/.." && pwd)}"
TENANT_DIR="${PULSAR_OS_HOME}/tenant"
ENV_FILE="${TENANT_DIR}/.env.local"
AGENTS_CFG="${TENANT_DIR}/agents-config.json"
WELCOME="${PULSAR_OS_HOME}/onboarding/welcome-script.md"

c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_red=$'\033[31m'; c_off=$'\033[0m'
say()   { printf "%s%s%s\n" "$c_bold" "$*" "$c_off"; }
muted() { printf "%s%s%s\n" "$c_dim" "$*" "$c_off"; }
ok()    { printf "%s✅ %s%s\n" "$c_green" "$*" "$c_off"; }
err()   { printf "%s❌ %s%s\n" "$c_red" "$*" "$c_off"; }

# ----- preflight ----------------------------------------------------------

[ -f "${ENV_FILE}" ] || { err "Env nao encontrado: ${ENV_FILE}. Rode bots-wizard antes."; exit 1; }
command -v jq >/dev/null 2>&1 || { err "jq nao instalado."; exit 1; }
command -v curl >/dev/null 2>&1 || { err "curl nao instalado."; exit 1; }

# carrega tokens (sem export pra logs nao vazarem)
PULSE_TOKEN="$(grep -E '^TELEGRAM_PULSE_BOT_TOKEN=' "${ENV_FILE}" | tail -1 | cut -d= -f2- | sed 's/^"//;s/"$//')"
PULSE_USERNAME="$(grep -E '^TELEGRAM_PULSE_BOT_TOKEN_USERNAME=' "${ENV_FILE}" | tail -1 | cut -d= -f2- | sed 's/^"//;s/"$//')"

[ -n "${PULSE_TOKEN}" ] || { err "TELEGRAM_PULSE_BOT_TOKEN vazio."; exit 1; }

# ----- captura chat_id ----------------------------------------------------

say "—— Smoke: primeira mensagem do Pulse ——"
muted "Vou capturar seu chat_id automaticamente quando voce digitar /start no @${PULSE_USERNAME:-Pulse}."

CHAT_ID=""
EXISTING_CHAT_ID=""
if [ -f "${AGENTS_CFG}" ]; then
  EXISTING_CHAT_ID="$(jq -r '.tenant.contacts.founder_chat_id // ""' "${AGENTS_CFG}" 2>/dev/null || echo "")"
fi

if [ -n "${EXISTING_CHAT_ID}" ] && [ "${EXISTING_CHAT_ID}" != "null" ]; then
  ok "chat_id ja salvo: ${EXISTING_CHAT_ID}"
  CHAT_ID="${EXISTING_CHAT_ID}"
else
  say "1) Abre o Telegram"
  say "2) Busca @${PULSE_USERNAME:-seu_pulse_bot}"
  say "3) Aperta INICIAR (ou digita /start)"
  say ""
  muted "Aguardando 60s pelo /start..."

  POLL_DEADLINE=$(( $(date +%s) + 60 ))
  while [ "$(date +%s)" -lt "${POLL_DEADLINE}" ]; do
    UPDATES="$(curl -fsS --max-time 8 "https://api.telegram.org/bot${PULSE_TOKEN}/getUpdates?timeout=5" 2>/dev/null || echo '{}')"
    CHAT_ID="$(printf "%s" "${UPDATES}" | jq -r '
      .result // []
      | map(.message // .edited_message)
      | map(select(. != null))
      | (map(select(.text == "/start")) + .)
      | .[0].chat.id // empty
    ' 2>/dev/null || echo "")"
    if [ -n "${CHAT_ID}" ]; then
      ok "chat_id capturado: ${CHAT_ID}"
      break
    fi
    sleep 3
  done

  if [ -z "${CHAT_ID}" ]; then
    err "Timeout. Manda /start no @${PULSE_USERNAME:-Pulse} e roda de novo: bash $(basename "$0")"
    exit 2
  fi
fi

# ----- persiste chat_id em agents-config.json -----------------------------

if [ ! -f "${AGENTS_CFG}" ]; then
  echo '{"tenant":{"contacts":{}}}' > "${AGENTS_CFG}"
fi

tmp="$(mktemp)"
jq --arg cid "${CHAT_ID}" '
  .tenant = (.tenant // {})
  | .tenant.contacts = (.tenant.contacts // {})
  | .tenant.contacts.founder_chat_id = $cid
' "${AGENTS_CFG}" > "${tmp}" && mv "${tmp}" "${AGENTS_CFG}"
ok "founder_chat_id persistido em ${AGENTS_CFG}"

# ----- renderiza msg 1 do welcome-script ---------------------------------

# Extrai bloco entre as cercas ``` da secao "Mensagem 1" do welcome-script.md.
# Fallback hardcoded caso parsing falhe.
MSG1=""
if [ -f "${WELCOME}" ]; then
  MSG1="$(awk '
    /^## Mensagem 1/ { in_section=1; next }
    /^## Mensagem 2/ { in_section=0 }
    in_section && /^```$/ { if (in_block) { in_block=0; exit } else { in_block=1; next } }
    in_section && in_block { print }
  ' "${WELCOME}")"
fi

if [ -z "${MSG1// /}" ]; then
  MSG1="Sou Pulseh. CEO digital da sua empresa a partir de hoje.

Antes de eu comecar a operar, preciso te entrevistar. Vou fazer 12 perguntas curtas — empresa, ICP, produto, time, dor de hoje. Voce escolhe se quer personalizar a inspiracao do meu time tambem.

Nao invento nada sobre voce. Se nao souber, prefiro deixar em branco a chutar."
fi

# ----- envia ---------------------------------------------------------------

say ""
say "Enviando primeira mensagem..."
SEND_RESP="$(curl -fsS --max-time 10 \
  -X POST "https://api.telegram.org/bot${PULSE_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG1}" \
  --data-urlencode "disable_web_page_preview=true" || echo '{"ok":false}')"

if [ "$(printf "%s" "${SEND_RESP}" | jq -r '.ok')" = "true" ]; then
  ok "Mensagem 1 entregue. Confere o Telegram."
else
  err "Falha no envio. Resp: ${SEND_RESP}"
  exit 3
fi

# ----- aguarda resposta (30s) ---------------------------------------------

say ""
muted "Aguardando 30s pra ver se voce responde..."
LAST_UPDATE_ID=0
WAIT_DEADLINE=$(( $(date +%s) + 30 ))
GOT_REPLY=0
while [ "$(date +%s)" -lt "${WAIT_DEADLINE}" ]; do
  UPDATES="$(curl -fsS --max-time 8 "https://api.telegram.org/bot${PULSE_TOKEN}/getUpdates?offset=${LAST_UPDATE_ID}" 2>/dev/null || echo '{}')"
  COUNT="$(printf "%s" "${UPDATES}" | jq -r '.result | length' 2>/dev/null || echo 0)"
  if [ "${COUNT}" -gt 0 ]; then
    LATEST_TEXT="$(printf "%s" "${UPDATES}" | jq -r --arg cid "${CHAT_ID}" '
      .result | map(select((.message.chat.id // .edited_message.chat.id) | tostring == $cid))
      | last | (.message.text // .edited_message.text // "")
    ' 2>/dev/null || echo "")"
    if [ -n "${LATEST_TEXT}" ] && [ "${LATEST_TEXT}" != "/start" ]; then
      ok "Resposta recebida: ${LATEST_TEXT}"
      GOT_REPLY=1
      break
    fi
  fi
  sleep 3
done

if [ "${GOT_REPLY}" -eq 1 ]; then
  ok "Pulse pronto pra entrar no interview-tree (P1: nome da empresa)."
  muted "Proximo passo (Iniciativa 3): pulsar-os onboarding-resume"
else
  muted "Sem resposta ainda. Tudo certo — quando voce responder, Pulse retoma."
fi

say ""
ok "Smoke concluido. Rode 'bash installer/smoke/validate.sh' pra checklist final."
