#!/bin/bash
# Pulsar OS · Wizard de instalacao
# v0.1.0 MVP · idempotente
# Roda na VPS do lojista Claro · cria estrutura agentica Clara (4 agentes)

set -e

VERSION="0.1.0"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "============================================="
echo "  PULSAR OS · v${VERSION}"
echo "  Setup wizard · estrutura agentica Clara"
echo "============================================="
echo

# --- 1. Detect environment ---
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Rode como root: sudo ./setup-pulsar-os.sh"
  exit 1
fi

# --- 2. Install paths ---
read -p "Caminho de instalacao [/opt/pulsar-os]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/opt/pulsar-os}
echo "==> Instalando em $INSTALL_PATH"

# --- 3. AI provider choice ---
echo
echo "Qual provider de IA voce vai usar?"
echo "  1) Anthropic Claude (recomendado · Claude Code)"
echo "  2) OpenAI Codex (alternativa)"
read -p "Escolha [1]: " AI_CHOICE
AI_CHOICE=${AI_CHOICE:-1}

if [ "$AI_CHOICE" = "1" ]; then
  AI_PROVIDER="anthropic"
  read -p "ANTHROPIC_API_KEY (ou cole token oauth Claude Code): " AI_TOKEN
elif [ "$AI_CHOICE" = "2" ]; then
  AI_PROVIDER="openai"
  read -p "OPENAI_API_KEY: " AI_TOKEN
else
  echo "Opcao invalida"; exit 1
fi

# --- 4. Telegram bot ---
echo
echo "Token do bot Telegram (cria em @BotFather)"
echo "Deixe vazio se nao quer Telegram ainda · da pra configurar depois."
read -p "TELEGRAM_BOT_TOKEN: " TG_TOKEN
read -p "Seu user_id Telegram (ALLOWED_USERS · pega em @userinfobot): " TG_USER

# --- 5. Lojista email (commits assinados) ---
echo
read -p "Seu email (para commits git): " LOJISTA_EMAIL
read -p "Seu nome (para commits git): " LOJISTA_NAME

# --- 6. Optional Vercel domain ---
echo
read -p "Dominio Vercel (opcional · ex: minhaloja.com.br · enter pra pular): " VERCEL_DOMAIN

# --- 7. Generate install ID (telemetria anonima) ---
INSTALL_ID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")

# --- 8. Create directory tree ---
echo
echo "==> Criando estrutura em $INSTALL_PATH..."
mkdir -p "$INSTALL_PATH"/{bot/{inbox,outbox,sent,processed,state,logs,audio/{incoming,outgoing}},workspace/{cerebro/{agents,skills,memory},knowledge,projetos,logs},logs}

# --- 9. Copy templates from repo ---
echo "==> Copiando templates..."
cp -r "$REPO_ROOT/workspace/cerebro/" "$INSTALL_PATH/workspace/"
cp "$REPO_ROOT/workspace/CLAUDE.md" "$INSTALL_PATH/workspace/CLAUDE.md"
cp "$REPO_ROOT/bot/telegram-bot.py" "$INSTALL_PATH/bot/telegram-bot.py"

# --- 10. Generate .env ---
echo "==> Gerando .env..."
cat > "$INSTALL_PATH/bot/.env" <<EOF
# Pulsar OS · install $INSTALL_ID
TELEGRAM_BOT_TOKEN=${TG_TOKEN:-PLACEHOLDER}
ALLOWED_USERS=${TG_USER:-PLACEHOLDER}
TMUX_SESSION=clara
TMUX_USER=$(stat -c '%U' "$INSTALL_PATH")

# AI provider
AI_PROVIDER=$AI_PROVIDER
EOF

if [ "$AI_PROVIDER" = "anthropic" ]; then
  echo "CLAUDE_CODE_OAUTH_TOKEN=$AI_TOKEN" >> "$INSTALL_PATH/bot/.env"
else
  echo "OPENAI_API_KEY=$AI_TOKEN" >> "$INSTALL_PATH/bot/.env"
fi

cat >> "$INSTALL_PATH/bot/.env" <<EOF

# Pulsar OS · telemetria anonima
PULSAR_OS_INSTALL_ID=$INSTALL_ID
PULSAR_OS_VERSION=$VERSION
PULSAR_OS_HEARTBEAT_URL=https://pulsarh.com.br/api/pulsar-os/heartbeat
EOF

chmod 600 "$INSTALL_PATH/bot/.env"

# --- 11. Install ID file ---
echo "$INSTALL_ID" > "$INSTALL_PATH/.pulsar-os-id"
echo "$VERSION" > "$INSTALL_PATH/.pulsar-os-version"

# --- 12. Git config local ---
if [ -n "$LOJISTA_EMAIL" ] && [ -n "$LOJISTA_NAME" ]; then
  cd "$INSTALL_PATH"
  git init -q 2>/dev/null || true
  git config user.email "$LOJISTA_EMAIL"
  git config user.name "$LOJISTA_NAME"
  cd - >/dev/null
fi

# --- 13. Vercel optional ---
if [ -n "$VERCEL_DOMAIN" ]; then
  echo "VERCEL_DOMAIN=$VERCEL_DOMAIN" >> "$INSTALL_PATH/bot/.env"
fi

# --- 14. Systemd service ---
echo "==> Instalando systemd service..."
cat > /etc/systemd/system/pulsar-os-clara-bot.service <<EOF
[Unit]
Description=Pulsar OS · Clara Telegram Bot · install $INSTALL_ID
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=10

[Service]
Type=simple
User=$(stat -c '%U' "$INSTALL_PATH")
Group=$(stat -c '%G' "$INSTALL_PATH")
WorkingDirectory=$INSTALL_PATH/bot
Environment=BOT_DIR=$INSTALL_PATH/bot
ExecStart=/usr/bin/python3 $INSTALL_PATH/bot/telegram-bot.py
Restart=always
RestartSec=5
StandardOutput=append:$INSTALL_PATH/bot/logs/systemd.log
StandardError=append:$INSTALL_PATH/bot/logs/systemd.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# --- 15. Postgres via Docker ---
echo
read -p "Subir Postgres local via Docker agora? [s/N]: " UP_DB
if [[ "$UP_DB" =~ ^[Ss]$ ]]; then
  if command -v docker >/dev/null 2>&1; then
    docker run -d --name pulsar-os-db \
      -e POSTGRES_PASSWORD=$(openssl rand -hex 16) \
      -e POSTGRES_DB=pulsar_os \
      -p 5433:5432 \
      -v pulsar-os-db-data:/var/lib/postgresql/data \
      postgres:15 2>&1 | tail -5
    echo "==> Postgres em localhost:5433 · senha guardada em $INSTALL_PATH/bot/.env"
  else
    echo "Docker nao encontrado · pule essa etapa ou instale Docker."
  fi
fi

# --- 16. Telemetria heartbeat (cron) ---
echo
echo "==> Configurando heartbeat anonimo (1x/dia)..."
HEARTBEAT_CMD="curl -s -X POST -H 'Content-Type: application/json' -d '{\"installId\":\"$INSTALL_ID\",\"version\":\"$VERSION\",\"lastActive\":\"\$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}' https://pulsarh.com.br/api/pulsar-os/heartbeat >/dev/null 2>&1"
(crontab -l 2>/dev/null | grep -v "pulsar-os/heartbeat" ; echo "0 9 * * * $HEARTBEAT_CMD") | crontab -

# --- 17. Start bot? ---
echo
echo "============================================="
echo "  INSTALACAO COMPLETA"
echo "============================================="
echo "  install_id: $INSTALL_ID"
echo "  versao: $VERSION"
echo "  caminho: $INSTALL_PATH"
echo "  provider: $AI_PROVIDER"
echo "  telegram: $([ -n "$TG_TOKEN" ] && echo "configurado" || echo "DESATIVADO · configure depois em $INSTALL_PATH/bot/.env")"
echo "============================================="
echo
if [ -n "$TG_TOKEN" ]; then
  read -p "Iniciar bot agora? [S/n]: " START_NOW
  START_NOW=${START_NOW:-s}
  if [[ "$START_NOW" =~ ^[Ss]$ ]]; then
    systemctl enable pulsar-os-clara-bot.service
    systemctl start pulsar-os-clara-bot.service
    sleep 2
    systemctl status pulsar-os-clara-bot.service --no-pager | head -10
  fi
fi

echo
echo "PROXIMOS PASSOS:"
echo "  1. Manda /start no seu bot Telegram pra testar"
echo "  2. Le o guia: $REPO_ROOT/docs/onboarding.md"
echo "  3. Editar Souls em $INSTALL_PATH/workspace/cerebro/agents/"
echo "  4. Quando receber docs Claro do Rodrigo · atualizar $INSTALL_PATH/workspace/cerebro/skills/comercial-planos-claro.md"
echo
echo "Status: systemctl status pulsar-os-clara-bot.service"
echo "Logs:   tail -f $INSTALL_PATH/bot/logs/bot.log"
echo
