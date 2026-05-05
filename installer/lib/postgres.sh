#!/usr/bin/env bash
# Sobe Postgres via docker-compose, aplica schema, roda seed

provision_postgres() {
  if state_done "postgres"; then ok "Postgres ja provisionado"; return; fi
  step "[4/8] Provisionando Postgres (docker-compose + schema + seed)"

  local compose_file="${INSTALLER_DIR}/docker-compose.yml"
  local schema_file="${INSTALLER_DIR}/postgres/schema.sql"
  local seed_file="${INSTALLER_DIR}/postgres/seed.sql"

  [[ -f "${compose_file}" ]] || err "docker-compose.yml nao encontrado em ${compose_file}"
  [[ -f "${schema_file}" ]] || err "schema.sql nao encontrado em ${schema_file}"
  [[ -f "${seed_file}" ]] || err "seed.sql nao encontrado em ${seed_file}"

  # Gera senha random e salva em .env
  local env_file="${STATE_DIR}/postgres.env"
  if [[ ! -f "${env_file}" ]]; then
    local pg_pass
    pg_pass=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)
    cat > "${env_file}" <<EOF
POSTGRES_USER=pulsar
POSTGRES_PASSWORD=${pg_pass}
POSTGRES_DB=pulsar_os
DATABASE_URL=postgresql://pulsar:${pg_pass}@localhost:5432/pulsar_os
EOF
    ok ".env Postgres gerado"
  fi
  # shellcheck source=/dev/null
  source "${env_file}"

  # Sobe container
  info "Subindo container postgres..."
  docker compose --env-file "${env_file}" -f "${compose_file}" up -d postgres

  # Wait healthcheck
  info "Aguardando Postgres ready (max 60s)..."
  for i in {1..60}; do
    if docker compose -f "${compose_file}" exec -T postgres pg_isready -U "${POSTGRES_USER}" >/dev/null 2>&1; then
      ok "Postgres ready"
      break
    fi
    sleep 1
    [[ $i -eq 60 ]] && err "Postgres nao ficou ready em 60s"
  done

  # Aplica schema (idempotente — usa CREATE TABLE IF NOT EXISTS)
  info "Aplicando schema.sql..."
  PGPASSWORD="${POSTGRES_PASSWORD}" psql -h localhost -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -v ON_ERROR_STOP=1 -f "${schema_file}" >/dev/null
  ok "Schema aplicado"

  # Aplica seed (idempotente — ON CONFLICT DO NOTHING)
  info "Rodando seed.sql (30 agents + 23 skills + brand tokens)..."
  PGPASSWORD="${POSTGRES_PASSWORD}" psql -h localhost -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -v ON_ERROR_STOP=1 -f "${seed_file}" >/dev/null
  ok "Seed aplicado"

  state_mark "postgres"
}
