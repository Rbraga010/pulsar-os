# syntax=docker/dockerfile:1.7
#
# Clara · Pulsar OS · Imagem distribuível pro lojista mentorado PulsarH.AI
# Multi-stage · objetivo final < 1.5GB · sem secrets embutidos.
#
# Stage 1 (builder): instala compiladores pesados + deps Node das tools
# Stage 2 (runtime): só o necessário pra rodar o claude --channels em tmux
#
# Ref blueprint: clara.service no host (systemd + tmux + agent-loop.sh)


# ─────────────────────────────────────────────────────────────────
# Stage 1 · BUILDER
# ─────────────────────────────────────────────────────────────────
FROM node:22-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Compiladores + libs nativas pesadas (só no builder)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    build-essential pkg-config \
    tesseract-ocr tesseract-ocr-por tesseract-ocr-eng \
    imagemagick \
    sqlite3 \
    poppler-utils \
    ffmpeg \
    chromium \
    curl git tmux bash util-linux gnupg ca-certificates \
    libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 \
    fonts-liberation fonts-noto-color-emoji \
 && rm -rf /var/lib/apt/lists/*

# Bun (necessário pro plugin Telegram oficial)
ENV BUN_INSTALL=/usr/local/bun
ENV PATH=${BUN_INSTALL}/bin:${PATH}
RUN curl -fsSL https://bun.sh/install | bash \
 && bun --version

# Claude Code CLI (motor Claude Max usa esse binário)
RUN npm install -g @anthropic-ai/claude-code \
 && claude --version

# Codex CLI da OpenAI (motor alternativo · pacote pode mudar de nome com o tempo)
# Tenta o nome oficial primeiro; se não estiver publicado, segue sem quebrar o build.
RUN (npm install -g @openai/codex || npm install -g @openai/codex-cli || echo "codex CLI não publicado · lojista instala runtime") \
 && (codex --version 2>/dev/null || echo "codex CLI ausente · sem problema, Claude Max é o motor default")

# Deps Python globais (cobrem todas as tools Python)
RUN pip3 install --no-cache-dir \
    requests \
    beautifulsoup4 \
    google-cloud-texttospeech \
    google-auth-oauthlib \
    google-auth-httplib2 \
    google-api-python-client \
    qrcode \
    Pillow \
    openai \
    duckduckgo-search

# Copia workspace inteiro · vamos instalar deps Node dentro dele
# Build context é /opt/clones/clara/ · então workspace/ é direto
COPY workspace /build/workspace

WORKDIR /build/workspace

# Limpa node_modules que vieram do host (.dockerignore deveria ter excluído, mas garante)
RUN find tools -type d -name node_modules -prune -exec rm -rf {} + 2>/dev/null || true

# Instala deps Node de cada tool · sempre volta pro WORKDIR antes de avaliar $dir
RUN set -e; \
    for dir in tools/carousel-renderer tools/whatsapp-baileys tools/video-remotion; do \
      cd /build/workspace; \
      if [ -f "$dir/package.json" ]; then \
        echo ">>> npm install em $dir"; \
        ( cd "$dir" && npm install --no-audit --no-fund --omit=dev ) || \
          (echo "FALHOU npm install em $dir" && exit 1); \
      else \
        echo "SKIP $dir · sem package.json"; \
      fi; \
    done

# Plugin Telegram NÃO vem embutido na imagem · instala em runtime no entrypoint
# (depois do motor logar) via `claude plugin install telegram@claude-plugins-official`.
# Isso mantém o build reprodutível sem depender do .claude/plugins do build host.


# ─────────────────────────────────────────────────────────────────
# Stage 2 · RUNTIME
# ─────────────────────────────────────────────────────────────────
FROM node:22-bookworm AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    HOME=/root \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=America/Sao_Paulo

# Só o runtime · sem build-essential nem -dev
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    tesseract-ocr tesseract-ocr-por tesseract-ocr-eng \
    imagemagick \
    sqlite3 \
    poppler-utils \
    ffmpeg \
    chromium \
    tmux bash util-linux ca-certificates curl \
    libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 \
    fonts-liberation fonts-noto-color-emoji \
    tini \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Copia bun do builder (binário + libs)
COPY --from=builder /usr/local/bun /usr/local/bun

# Node global modules (claude CLI + codex se houver)
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules

# Deps Python site-packages (instaladas no builder via pip --break-system-packages)
COPY --from=builder /usr/local/lib/python3.11/dist-packages /usr/local/lib/python3.11/dist-packages

# /usr/local/bin do builder · tem claude, codex (se publicado), bins Python (qrcode etc)
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Workspace já com node_modules das tools
COPY --from=builder /build/workspace /workspace

# Scripts (build context é a raiz do repo · scripts vivem em docker/)
COPY docker/agent-loop.sh /usr/local/bin/agent-loop.sh
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/agent-loop.sh /usr/local/bin/entrypoint.sh

# PATH global · bun na frente pra plugin funcionar
ENV PATH="/usr/local/bun/bin:/usr/local/bin:/usr/bin:/bin" \
    PYTHONUNBUFFERED=1 \
    CLARA_AGENT=clara \
    WORKSPACE_DIR=/workspace \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROMIUM_FLAGS="--no-sandbox --disable-gpu --headless=new"

WORKDIR /workspace

# Volumes pra estado persistente (dados do lojista NUNCA são parte da imagem)
VOLUME ["/root/.claude", "/workspace/cerebro/memory", "/workspace/data"]

# Tini como PID 1 cuida de signals (SIGTERM dá graceful shutdown no tmux)
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
