#!/usr/bin/env bash
#
# Rentabiliza.ai · install wizard pra Clara (sócia agêntica do lojista)
# v0.3.0
#
# Uso: curl -fsSL https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/install.sh | sudo bash
#  ou: ./install.sh   (depois de git clone)
#
# Pré-req: VPS Linux (Ubuntu 22.04 LTS recomendado · Debian/Fedora também). 2GB RAM. Root.
#
# O que faz, na ordem:
#  1. Pergunta caminho de instalação (default /opt/rentabiliza-ai)
#  2. Detecta + instala Docker se faltar
#  3. Clona/atualiza repo
#  4. Pergunta SOMENTE o token do bot Telegram (chat_id é detectado automaticamente
#     via pairing quando o lojista mandar /start no bot)
#  5. Escreve .env
#  6. Sobe stack (docker compose up -d)
#  7. Instrui pra rodar `docker exec -it clara claude login` (ou codex)
#  8. Mostra como falar com o bot pelo Telegram

set -euo pipefail

VERSION="0.3.0"
REPO_URL="${PULSAR_REPO_URL:-https://github.com/Rbraga010/pulsar-os.git}"
DEFAULT_PATH="/opt/rentabiliza-ai"

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
  │   RENTABILIZA.AI · Clara                    │
  │   a sócia agêntica do seu negócio           │
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
    say "Clonando repo Rentabiliza.ai"
    mkdir -p "$(dirname "$INSTALL_PATH")"
    git clone --depth 1 "$REPO_URL" "$INSTALL_PATH"
  fi
  ok "Repo em $INSTALL_PATH"
}

# ── 4 · telegram (somente token · chat_id detectado via pairing) ────
ask_telegram() {
  cat <<EOF

${BOLD}── BOT TELEGRAM ──${RESET}

Você só precisa de 1 coisinha · em 1 minuto:

  - abre @BotFather no Telegram
  - manda /newbot
  - dá um nome (ex: "Clara da sua loja") e username terminando em _bot
  - copia o token que ele te manda

Depois da instalação, quando você mandar a primeira mensagem
pro seu bot, a Clara reconhece automaticamente que é você
(pairing). Nada de chat_id, configuração extra, nada.

EOF
  read -rp "${BOLD}Token do bot Telegram:${RESET} " TG_TOKEN < /dev/tty
  [ -z "$TG_TOKEN" ] && die "Token vazio · não dá pra subir sem isso"

  ok "Telegram configurado · pairing fica armado pra primeira /start"
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
brain_login() {
  cat <<EOF

${BOLD}── ESCOLHE O CÉREBRO DA CLARA ──${RESET}

O cérebro da Clara é uma sessão sua de Claude Max ou ChatGPT Plus
(você já paga · agora aproveita). Loga 1 vez · persiste pra sempre.

  ${BOLD}A)${RESET} Claude Max (Anthropic · recomendado)
  ${BOLD}B)${RESET} Codex (OpenAI ChatGPT Plus/Pro)
  ${BOLD}P)${RESET} Pular · faço depois manualmente

EOF

  # Detecta se temos TTY pra modo interativo
  if [ ! -t 0 ]; then
    warn "Sem TTY (rodando via curl-pipe-bash · OK) · não dá pra abrir login interativo daqui."
    warn "DEPOIS dessa instalação, abre OUTRO terminal e roda manualmente:"
    echo "    docker exec -it clara claude login"
    echo "    (ou: docker exec -it clara codex login)"
    return 0
  fi

  read -rp "${BOLD}Escolha [A/B/P]:${RESET} " BRAIN < /dev/tty || BRAIN="P"
  case "${BRAIN^^}" in
    A)
      say "Abrindo claude login interativo · loga no navegador e volta aqui"
      docker exec -it clara claude login || warn "claude login falhou · roda manual depois: docker exec -it clara claude login"
      ;;
    B)
      say "Abrindo codex login interativo · loga no navegador e volta aqui"
      docker exec -it clara codex login || warn "codex login falhou · roda manual depois: docker exec -it clara codex login"
      ;;
    *)
      warn "Pulado · lembra de rodar depois: docker exec -it clara claude login (ou codex login)"
      ;;
  esac
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
write_env
boot_stack
brain_login
final_handshake
