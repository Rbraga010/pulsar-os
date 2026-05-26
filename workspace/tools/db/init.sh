#!/usr/bin/env bash
# Clara · inicializa SQLite DB local
# Idempotente: pode rodar várias vezes (CREATE TABLE IF NOT EXISTS)

set -euo pipefail

DB_DIR="/opt/clones/clara/workspace/data"
DB_PATH="${DB_DIR}/clara.db"
SCHEMA="$(dirname "$(readlink -f "$0")")/schema.sql"

mkdir -p "${DB_DIR}"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "ERRO: sqlite3 não instalado. Rode: apt install sqlite3" >&2
  exit 1
fi

if [ ! -f "${SCHEMA}" ]; then
  echo "ERRO: schema não encontrado em ${SCHEMA}" >&2
  exit 1
fi

# backup antes de aplicar (preserva data caso já exista)
if [ -f "${DB_PATH}" ]; then
  cp "${DB_PATH}" "${DB_PATH}.backup-$(date +%s)"
fi

sqlite3 "${DB_PATH}" < "${SCHEMA}"

echo "[init] DB pronto em ${DB_PATH}"
echo "[init] tabelas:"
sqlite3 "${DB_PATH}" ".tables"
