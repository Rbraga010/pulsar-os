#!/bin/bash
# Clara · entrypoint do container
# Faz toda a higiene antes de subir o tmux/claude:
#   1) garante motor de inteligência logado (Claude Max ou Codex)
#   2) garante token Telegram + access.json em /root/.claude/channels/telegram-clara/
#   3) garante trust do workspace em ~/.claude.json (hasTrustDialogAccepted)
#   4) garante /workspace/.claude/settings.json com plugin Telegram habilitado
#   5) dispara tmux session "clara" rodando agent-loop.sh
#
# Variáveis OBRIGATÓRIAS do compose:
#   TELEGRAM_BOT_TOKEN · token do bot do Telegram do lojista
#   CHAT_ID_OWNER      · chat_id do Telegram do dono (pra pairing automático)
#
# Variáveis OPCIONAIS:
#   GOOGLE_AI_API_KEY · image-gen
#   OPENAI_API_KEY · tts fallback
#   GOOGLE_APPLICATION_CREDENTIALS · tts Google + google-workspace
#   BRAVE_SEARCH_API_KEY · websearch premium
#
# Override pra smoke test:
#   ENTRYPOINT_MODE=test · pula o loop · só roda sanity checks e dorme

set -uo pipefail

log() { printf "[clara-entrypoint %s] %s\n" "$(date -u +%H:%M:%S)" "$*"; }
fail() { log "ERRO: $*"; exit 1; }

# ─────────────────────────────────────────────────────────────────
# MODO TESTE · pula tudo, só dorme (smoke test usa exec pra validar deps)
# ─────────────────────────────────────────────────────────────────
if [ "${ENTRYPOINT_MODE:-}" = "test" ]; then
  log "Modo teste · pulando inicialização do claude · container fica vivo pra smoke test"
  exec tail -f /dev/null
fi

# ─────────────────────────────────────────────────────────────────
# 1) Sanity checks de binários
# ─────────────────────────────────────────────────────────────────
log "Verificando binários essenciais..."
command -v claude >/dev/null || fail "claude CLI não encontrado · imagem corrompida"
command -v bun >/dev/null    || fail "bun não encontrado · plugin Telegram não vai subir"
command -v tmux >/dev/null   || fail "tmux não encontrado"
command -v python3 >/dev/null || fail "python3 não encontrado · tools quebram"
command -v node >/dev/null    || fail "node não encontrado · tools quebram"

# ─────────────────────────────────────────────────────────────────
# 2) Motor de inteligência · Claude Max OU Codex
# ─────────────────────────────────────────────────────────────────
CLAUDE_JSON="$HOME/.claude.json"
CODEX_DIR="$HOME/.codex"

motor_logado() {
  # Claude Max: ~/.claude.json existe com oauthAccount preenchido
  if [ -f "$CLAUDE_JSON" ] && grep -q '"oauthAccount"' "$CLAUDE_JSON" 2>/dev/null; then
    return 0
  fi
  # Codex: ~/.codex/auth.json existe (heurística · ajustar quando Codex CLI estabilizar)
  if [ -d "$CODEX_DIR" ] && [ -f "$CODEX_DIR/auth.json" ]; then
    return 0
  fi
  return 1
}

if ! motor_logado; then
  log "============================================================"
  log "Nenhum motor de inteligência logado."
  log ""
  log "Abre OUTRO terminal e roda UM dos dois comandos:"
  log ""
  log "  Opção A (recomendado · Claude Max da Anthropic):"
  log "    docker exec -it clara claude login"
  log ""
  log "  Opção B (Codex OpenAI · ChatGPT Plus/Pro):"
  log "    docker exec -it clara codex login"
  log ""
  log "Sigo aguardando · checo a cada 10s."
  log "============================================================"
  while ! motor_logado; do
    sleep 10
  done
  log "Motor detectado · continuando setup."
fi
log "OK · motor de inteligência presente."

# ─────────────────────────────────────────────────────────────────
# 2.5) Plugin Telegram · instala se ainda não está
# ─────────────────────────────────────────────────────────────────
PLUGINS_DIR="/root/.claude/plugins"
TELEGRAM_INSTALLED=0
if [ -f "$PLUGINS_DIR/installed_plugins.json" ] && \
   grep -q "telegram@claude-plugins-official" "$PLUGINS_DIR/installed_plugins.json" 2>/dev/null; then
  TELEGRAM_INSTALLED=1
fi

if [ "$TELEGRAM_INSTALLED" = "0" ]; then
  log "Plugin Telegram não encontrado · instalando (30-60s na primeira vez)"
  # Adiciona o marketplace e instala o plugin
  claude plugin marketplace add claude-plugins-official 2>&1 | head -20 || true
  claude plugin install telegram@claude-plugins-official 2>&1 | head -20 || \
    log "AVISO: falhou instalar plugin Telegram automático · rode manual: docker exec -it clara claude plugin install telegram@claude-plugins-official"
fi
log "OK · plugin Telegram pronto."

# ─────────────────────────────────────────────────────────────────
# 3) Telegram · token + access.json
# ─────────────────────────────────────────────────────────────────
CHANNEL_DIR="/root/.claude/channels/telegram-clara"
mkdir -p "$CHANNEL_DIR/approved" "$CHANNEL_DIR/inbox"

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
  fail "TELEGRAM_BOT_TOKEN não configurado no .env do compose"
fi

# Atualiza .env do channel (sempre · permite trocar token sem rebuild)
ENV_FILE="$CHANNEL_DIR/.env"
echo "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" > "$ENV_FILE"
chmod 600 "$ENV_FILE"
log "OK · .env do channel atualizado em $ENV_FILE"

# access.json · se não existir, cria com CHAT_ID_OWNER no allowlist
ACCESS_FILE="$CHANNEL_DIR/access.json"
if [ ! -f "$ACCESS_FILE" ]; then
  CHAT_OWNER="${CHAT_ID_OWNER:-}"
  if [ -n "$CHAT_OWNER" ]; then
    log "Criando access.json com CHAT_ID_OWNER=$CHAT_OWNER no allowlist"
    cat > "$ACCESS_FILE" <<EOF
{
  "dmPolicy": "pairing",
  "allowFrom": ["${CHAT_OWNER}"],
  "groups": {},
  "pending": {}
}
EOF
  else
    log "AVISO: CHAT_ID_OWNER não setado · criando access.json com pairing aberto · aprove via skill telegram:access depois"
    cat > "$ACCESS_FILE" <<EOF
{
  "dmPolicy": "pairing",
  "allowFrom": [],
  "groups": {},
  "pending": {}
}
EOF
  fi
fi
log "OK · access.json em $ACCESS_FILE"

# ─────────────────────────────────────────────────────────────────
# 4) Trust dialog · workspace
# ─────────────────────────────────────────────────────────────────
WORKDIR="${WORKSPACE_DIR:-/workspace}"
python3 - "$WORKDIR" "$CLAUDE_JSON" <<'PYEOF' || log "AVISO: falhou setar trust · claude pode pedir confirmação na primeira run"
import json, os, sys
workdir, claude_json = sys.argv[1], sys.argv[2]

if not os.path.exists(claude_json):
    data = {}
else:
    with open(claude_json) as f:
        data = json.load(f)

data.setdefault("projects", {})
proj = data["projects"].setdefault(workdir, {})
proj["hasTrustDialogAccepted"] = True
proj["hasCompletedProjectOnboarding"] = True

with open(claude_json, "w") as f:
    json.dump(data, f, indent=2)
print(f"trust OK · {workdir}")
PYEOF

# ─────────────────────────────────────────────────────────────────
# 5) settings.json do workspace · plugin Telegram habilitado
# ─────────────────────────────────────────────────────────────────
SETTINGS_FILE="$WORKDIR/.claude/settings.json"
mkdir -p "$WORKDIR/.claude"
if [ ! -f "$SETTINGS_FILE" ]; then
  log "Criando $SETTINGS_FILE default"
  cat > "$SETTINGS_FILE" <<'EOF'
{
  "permissions": {
    "allow": [
      "mcp__plugin_telegram_telegram__*",
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(*)", "WebSearch", "WebFetch", "Agent"
    ]
  },
  "allowedTools": [
    "mcp__plugin_telegram_telegram__*",
    "Read", "Write", "Edit", "Glob", "Grep",
    "Bash(*)", "WebSearch", "WebFetch", "Agent"
  ],
  "enabledPlugins": {
    "telegram@claude-plugins-official": true
  }
}
EOF
fi
log "OK · settings.json em $SETTINGS_FILE"

# ─────────────────────────────────────────────────────────────────
# 6) Sobe tmux + agent-loop
# ─────────────────────────────────────────────────────────────────
LOG_FILE="/var/log/clara-tui.log"
mkdir -p /var/log
touch "$LOG_FILE" 2>/dev/null || LOG_FILE=/tmp/clara-tui.log

log "Subindo tmux session 'clara' com agent-loop.sh..."
/usr/bin/tmux kill-session -t clara 2>/dev/null || true
/usr/bin/tmux new-session -d -s clara "/usr/local/bin/agent-loop.sh"

log "Container vivo · seguindo log em $LOG_FILE"
log "Pra entrar na sessão: docker exec -it clara tmux attach -t clara"
log "Pra sair sem matar: Ctrl+B depois D"

# Mantém PID 1 vivo + segue log
exec tail -F "$LOG_FILE"
