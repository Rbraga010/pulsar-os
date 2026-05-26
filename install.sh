#!/usr/bin/env bash
#
# Pulsar OS · install wizard pra Clara (sócia agêntica especialista Claro)
# v0.2.0
#
# Uso: curl -fsSL https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/install.sh | sudo bash
#  ou: ./install.sh   (depois de git clone)
#
# Pré-req: VPS ou PC com Linux (Ubuntu/Debian/Fedora). 2GB RAM. Root.
#
# O que faz, na ordem:
#  1. Pergunta caminho de instalação (default /opt/pulsar-os)
#  2. Detecta + instala Docker se faltar
#  3. Clona/atualiza repo
#  4. Pergunta token Telegram + chat_id (link pro BotFather/userinfobot)
#  5. Pergunta região Claro do lojista (pra book varejo regional)
#  6. Escreve .env
#  7. Sobe stack (docker compose up -d)
#  8. Instrui pra rodar `docker exec -it clara claude login` (ou codex)
#  9. Mostra o handle do bot pro lojista mandar /start

set -euo pipefail

VERSION="0.2.0"
REPO_URL="${PULSAR_REPO_URL:-https://github.com/Rbraga010/pulsar-os.git}"
DEFAULT_PATH="/opt/pulsar-os"

# ── helpers ──────────────────────────────────────────────────────────
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

say()  { printf "%s%s%s\n" "$BLUE" "$*" "$RESET"; }
ok()   { printf "%s✓ %s%s\n" "$GREEN" "$*" "$RESET"; }
warn() { printf "%s! %s%s\n" "$YELLOW" "$*" "$RESET"; }
die()  { printf "%s✗ %s%s\n" "$RED" "$*" "$RESET" >&2; exit 1; }

banner() {
  cat <<'EOF'

  ┌─────────────────────────────────────────────┐
  │                                             │
  │   PULSAR OS · Clara                         │
  │   sua sócia agêntica especialista Claro     │
  │                                             │
  └─────────────────────────────────────────────┘

EOF
}

# ── 0 · pré-flight ──────────────────────────────────────────────────
require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    die "Roda como root. Tenta: sudo $0"
  fi
}

# ── 1 · install path ───────────────────────────────────────────────
ask_install_path() {
  read -rp "${BOLD}Caminho de instalação${RESET} [$DEFAULT_PATH]: " INSTALL_PATH < /dev/tty || true
  INSTALL_PATH="${INSTALL_PATH:-$DEFAULT_PATH}"
  ok "Vai instalar em: $INSTALL_PATH"
}

# ── 2 · docker ──────────────────────────────────────────────────────
ensure_docker() {
  if command -v docker >/dev/null 2>&1; then
    ok "Docker já tá instalado · $(docker --version)"
  else
    warn "Docker não encontrado · instalando agora (script oficial)"
    curl -fsSL https://get.docker.com | sh
    ok "Docker instalado"
  fi

  if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose v2 disponível"
  else
    die "docker compose v2 não disponível · atualiza o Docker (versão 20.10+)"
  fi
}

# ── 3 · repo ────────────────────────────────────────────────────────
fetch_repo() {
  if [ -d "$INSTALL_PATH/.git" ]; then
    say "Repo já clonado · puxando últimas mudanças"
    git -C "$INSTALL_PATH" pull --ff-only
  else
    say "Clonando repo Pulsar OS"
    mkdir -p "$(dirname "$INSTALL_PATH")"
    git clone --depth 1 "$REPO_URL" "$INSTALL_PATH"
  fi
  ok "Repo em $INSTALL_PATH"
}

# ── 4 · telegram ────────────────────────────────────────────────────
ask_telegram() {
  cat <<EOF

${BOLD}── BOT TELEGRAM ──${RESET}

Você precisa de 2 coisinhas do Telegram:

  1) Token do bot · cria 1 minuto:
     - abre @BotFather no Telegram
     - manda /newbot
     - dá um nome (ex: "Clara da sua loja") e username terminando em _bot
     - copia o token que ele te manda

  2) Seu chat_id (pra Clara responder SÓ você):
     - abre @userinfobot no Telegram
     - manda /start
     - copia o número que ele te responde

EOF
  read -rp "${BOLD}Token do bot Telegram:${RESET} " TG_TOKEN < /dev/tty
  [ -z "$TG_TOKEN" ] && die "Token vazio · não dá pra subir sem isso"

  read -rp "${BOLD}Seu chat_id:${RESET} " CHAT_ID < /dev/tty
  [ -z "$CHAT_ID" ] && die "chat_id vazio · não dá pra subir sem isso"

  ok "Telegram configurado"
}

# ── 5 · região Claro ───────────────────────────────────────────────
ask_regiao() {
  cat <<EOF

${BOLD}── REGIÃO CLARO ──${RESET}

A Clara é especialista vendedora Claro. Preços do book de varejo
mudam por região · me diz a sua pra eu puxar o catálogo certo.

  1) SP Capital (default · book já embutido)
  2) Interior SP
  3) Rio de Janeiro
  4) Sul (PR/SC/RS)
  5) Nordeste
  6) Outra

EOF
  read -rp "${BOLD}Sua região [1]:${RESET} " R < /dev/tty || true
  case "${R:-1}" in
    1) REGIAO_CLARO="SP_CAPITAL" ;;
    2) REGIAO_CLARO="SP_INTERIOR" ;;
    3) REGIAO_CLARO="RJ" ;;
    4) REGIAO_CLARO="SUL" ;;
    5) REGIAO_CLARO="NORDESTE" ;;
    *) REGIAO_CLARO="OUTRA" ;;
  esac
  ok "Região: $REGIAO_CLARO (Clara vai pedir mais detalhe no onboarding)"
}

# ── 6 · .env ────────────────────────────────────────────────────────
write_env() {
  local env_file="$INSTALL_PATH/docker/.env"
  if [ -f "$env_file" ]; then
    cp "$env_file" "$env_file.bak.$(date +%s)"
    warn "$env_file já existia · backup salvo"
  fi

  cat > "$env_file" <<EOF
# Gerado pelo install.sh em $(date -Iseconds)
TELEGRAM_BOT_TOKEN=$TG_TOKEN
CHAT_ID_OWNER=$CHAT_ID
REGIAO_CLARO=$REGIAO_CLARO
EOF
  chmod 600 "$env_file"
  ok ".env escrito em $env_file (chmod 600 · só root lê)"
}

# ── 7 · sobe stack ─────────────────────────────────────────────────
boot_stack() {
  say "Puxando imagem oficial da Clara (ghcr.io/rbraga010/clara:latest · 1-2 min)"
  if ( cd "$INSTALL_PATH/docker" && docker compose pull 2>&1 | tail -5 ); then
    ok "Imagem baixada"
  else
    warn "Pull falhou · vou buildar local (5-10 min · vai tomar um café)"
    ( cd "$INSTALL_PATH/docker" && docker compose build )
  fi

  say "Subindo Clara em background"
  ( cd "$INSTALL_PATH/docker" && docker compose up -d )

  ok "Stack rodando"
  docker ps --filter "name=clara" --format "  ID: {{.ID}}  Status: {{.Status}}"
}

# ── 8 · login do cérebro ───────────────────────────────────────────
prompt_brain_login() {
  cat <<EOF

${BOLD}── FALTA SÓ 1 PASSO MANUAL ──${RESET}

O "cérebro" da Clara é uma sessão sua de Claude Max ou ChatGPT Plus
(você já paga · agora aproveita). Loga 1 vez, persistente pra sempre:

  ${BOLD}Opção A · Claude Max (recomendado):${RESET}
    docker exec -it clara claude login

  ${BOLD}Opção B · ChatGPT/Codex:${RESET}
    docker exec -it clara codex login

(O comando abre um link · você loga no navegador · pronto.)

EOF
}

# ── 9 · fala com ela ───────────────────────────────────────────────
final_handshake() {
  cat <<EOF

${GREEN}${BOLD}── PRONTO ──${RESET}

Agora abre o Telegram, procura o bot que você criou e manda:

  ${BOLD}/start${RESET}

Ou só "oi Clara". Ela vai te puxar pra um onboarding curtinho
(5-7 mensagens) pra descobrir loja, família, rotina e meta.

${BOLD}Comandos úteis:${RESET}
  Logs em tempo real:  cd $INSTALL_PATH/docker && docker compose logs -f
  Reiniciar:           cd $INSTALL_PATH/docker && docker compose restart
  Parar:               cd $INSTALL_PATH/docker && docker compose down
  Atualizar versão:    cd $INSTALL_PATH/docker && docker compose pull && docker compose up -d

Bug ou dúvida? https://github.com/Rbraga010/pulsar-os/issues

Bora vender, sócio.

EOF
}

# ── main ────────────────────────────────────────────────────────────
banner
require_root
ask_install_path
ensure_docker
fetch_repo
ask_telegram
ask_regiao
write_env
boot_stack
prompt_brain_login
final_handshake
