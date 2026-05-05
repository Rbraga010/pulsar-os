#!/usr/bin/env bash
# Cria esqueleto /tenant — onboarding-answers vazio + agents-config copia do default

write_tenant_skeleton() {
  if state_done "tenant_skel"; then ok "Tenant skeleton ja criado"; return; fi
  step "[7/8] Criando esqueleto /tenant/"

  local target="${PULSAR_OS_HOME:-$PWD}"
  local tenant_dir="${target}/tenant"
  mkdir -p "${tenant_dir}"

  # onboarding-answers.json vazio (Pulse preenche entrevistando)
  if [[ ! -f "${tenant_dir}/onboarding-answers.json" ]]; then
    cat > "${tenant_dir}/onboarding-answers.json" <<EOF
{
  "tenant_slug": "${PULSAR_TENANT_SLUG:-}",
  "tenant_name": "${PULSAR_TENANT_NAME:-}",
  "founder_first_name": "",
  "founder_bio": null,
  "icp_primary": null,
  "icp_secondary": null,
  "vocabulary": null,
  "products": [],
  "stage": "pending_interview",
  "interviewedAt": null
}
EOF
    ok "tenant/onboarding-answers.json criado"
  fi

  # agents-config copia do default
  if [[ ! -f "${tenant_dir}/agents-config.json" ]]; then
    cp "${target}/agents-config.default.json" "${tenant_dir}/agents-config.json"
    # Substitui slug PulsarH pelo do cliente (mantem identidades — cliente customiza depois)
    if command -v jq >/dev/null; then
      jq --arg s "${PULSAR_TENANT_SLUG:-pulsar-os}" --arg n "${PULSAR_TENANT_NAME:-Pulsar OS}" \
         '.tenant_slug = $s | .tenant_name = $n | .company_name = $n | .founder_first_name = ""' \
         "${tenant_dir}/agents-config.json" > "${tenant_dir}/agents-config.json.tmp" \
         && mv "${tenant_dir}/agents-config.json.tmp" "${tenant_dir}/agents-config.json"
    fi
    ok "tenant/agents-config.json criado (copia do default)"
  fi

  # CLAUDE.md vazio — Pulse escreve apos entrevista
  if [[ ! -f "${tenant_dir}/CLAUDE.md" ]]; then
    cat > "${tenant_dir}/CLAUDE.md" <<EOF
# ${PULSAR_TENANT_NAME:-Pulsar OS} — CLAUDE.md

> Este arquivo sera preenchido pelo Pulse apos a entrevista de onboarding.
> Nao edite manualmente — Pulse cuida. Para iniciar entrevista, mande /start no bot CEO.

stage: pending_interview
EOF
    ok "tenant/CLAUDE.md placeholder criado"
  fi

  state_mark "tenant_skel"

  step "[8/8] Marcacao final"
  ok "Instalacao 4a concluida"
}
