#!/usr/bin/env bash
# Instalacao de dependencias — docker, docker-compose, node, postgres-client, gh

install_dependencies() {
  if state_done "deps"; then ok "Dependencias ja instaladas"; return; fi
  step "[2/8] Instalando dependencias"

  apt-get update -qq

  # Docker
  if ! command -v docker >/dev/null 2>&1; then
    info "Instalando Docker..."
    curl -fsSL https://get.docker.com | sh
  fi
  ok "Docker $(docker --version | awk '{print $3}' | tr -d ',')"

  # Docker compose plugin (vem com docker moderno)
  if ! docker compose version >/dev/null 2>&1; then
    apt-get install -y docker-compose-plugin
  fi
  ok "docker compose $(docker compose version --short)"

  # Node 20 LTS via nodesource
  if ! command -v node >/dev/null 2>&1 || [[ "$(node -v | sed 's/v//' | cut -d. -f1)" -lt 18 ]]; then
    info "Instalando Node 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
  fi
  ok "Node $(node -v)"

  # Postgres client (psql) pra rodar seed/schema
  if ! command -v psql >/dev/null 2>&1; then
    apt-get install -y postgresql-client
  fi
  ok "psql $(psql --version | awk '{print $3}')"

  # gh cli (Vercel link via repo Github)
  if ! command -v gh >/dev/null 2>&1; then
    info "Instalando gh CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list
    apt-get update -qq && apt-get install -y gh
  fi
  ok "gh $(gh --version | head -1 | awk '{print $3}')"

  # Vercel CLI
  if ! command -v vercel >/dev/null 2>&1; then
    npm install -g vercel
  fi
  ok "vercel $(vercel --version)"

  # Utilitarios extras
  apt-get install -y curl git jq dnsutils ca-certificates openssl >/dev/null

  state_mark "deps"
}
