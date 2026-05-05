#!/usr/bin/env bash
# Setup do projeto Vercel — login, link, env vars, primeiro deploy

setup_vercel_project() {
  if state_done "vercel"; then ok "Vercel ja configurado"; return; fi
  step "[5/8] Configurando Vercel"

  local target="${PULSAR_OS_HOME:-$PWD}"

  # Garante que cliente esta logado
  if ! vercel whoami >/dev/null 2>&1; then
    info "Voce precisa logar na Vercel agora (browser ou device flow)"
    vercel login || err "vercel login falhou"
  fi
  local vc_user; vc_user=$(vercel whoami 2>/dev/null | tail -1)
  ok "Vercel: ${vc_user}"

  warn "CRITICO: confirma que '${vc_user}' usa email '${PULSAR_VERCEL_EMAIL:-?}' — caso contrario deploys vao falhar"

  # Link projeto (cria se nao existe)
  cd "${target}"
  if [[ ! -f .vercel/project.json ]]; then
    info "Linkando projeto Vercel..."
    vercel link --yes --project "${PULSAR_TENANT_SLUG:-pulsar-os}" || err "vercel link falhou"
  fi
  ok "Projeto Vercel linkado"

  # Env vars essenciais
  # shellcheck source=/dev/null
  source "${STATE_DIR}/postgres.env"
  info "Adicionando env vars na Vercel..."

  # Vercel nao tem upsert nativo — tenta add, se falhar (ja existe) tenta rm + add
  add_env() {
    local key="$1" val="$2"
    echo "${val}" | vercel env add "${key}" production 2>/dev/null \
      || (vercel env rm "${key}" production --yes 2>/dev/null; echo "${val}" | vercel env add "${key}" production)
  }

  add_env "DATABASE_URL" "${DATABASE_URL}"
  add_env "PULSAR_TENANT_SLUG" "${PULSAR_TENANT_SLUG:-pulsar-os}"
  add_env "PULSAR_TENANT_NAME" "${PULSAR_TENANT_NAME:-Pulsar OS}"
  add_env "PULSAR_TENANT_DOMAIN" "${PULSAR_TENANT_DOMAIN:-localhost}"
  add_env "PULSAR_BRAND_VERSION" "v1.0-half-light"
  add_env "MCP_WARROOM_URL" "http://${PULSAR_VPS_IP:-localhost}:8765"

  ok "Env vars na Vercel"

  # Validacao: primeiro deploy
  info "Rodando primeiro deploy de validacao (pode levar 60-180s)..."
  if vercel deploy --prod --yes 2>&1 | tee "${STATE_DIR}/vercel-first-deploy.log" | grep -qE "ERROR|❌|Error:"; then
    err "Primeiro deploy retornou ERROR. Veja ${STATE_DIR}/vercel-first-deploy.log. Provavel: email autor commit nao casa com conta Vercel."
  fi
  ok "Primeiro deploy OK"

  state_mark "vercel"
}
