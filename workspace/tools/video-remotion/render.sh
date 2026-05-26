#!/usr/bin/env bash
# render.sh · Clara · renderiza reel-15s 1080x1920 a partir de props.json
# Uso: bash render.sh <props.json> [--out=path.mp4]

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: bash render.sh <props.json> [--out=path.mp4]" >&2
  exit 1
fi

PROPS="$1"
shift || true

if [ ! -f "$PROPS" ]; then
  echo "[video] props.json não existe: $PROPS" >&2
  exit 1
fi

WORKSPACE="/opt/clones/clara/workspace"
TOOL_DIR="$WORKSPACE/tools/video-remotion"
OUT_DIR="$WORKSPACE/data/videos"
mkdir -p "$OUT_DIR"

OUT="$OUT_DIR/$(date -u +%Y-%m-%dT%H-%M-%S).mp4"
for arg in "$@"; do
  case "$arg" in
    --out=*) OUT="${arg#--out=}" ;;
  esac
done

cd "$TOOL_DIR"

# 1a execução · baixa deps (~200MB Remotion + Chromium · 1x só)
if [ ! -d "node_modules" ]; then
  echo "[video] primeira execução · npm install (vai demorar 2-3min)..." >&2
  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install --no-audit --no-fund >&2
fi

echo "[video] renderizando reel-15s -> $OUT" >&2
npx remotion render src/index.ts reel-15s "$OUT" \
  --props="$PROPS" \
  --codec=h264 \
  --log=warn \
  --concurrency=1 >&2

echo "[video] OK -> $OUT" >&2
# stdout limpo · só path
echo "$OUT"
