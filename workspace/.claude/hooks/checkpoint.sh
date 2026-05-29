#!/bin/bash
# Blindagem de memória · checkpoint automático (hook Stop · roda no fim de CADA turn).
# Grava heartbeat (última atividade) + snapshot das pendências abertas num arquivo que
# vive no volume persistente da memória (sobrevive a restart/recreate do container).
# SEMPRE sai 0 — nunca bloqueia a resposta da Clara.
set +e
DIR="${CLAUDE_PROJECT_DIR:-/workspace}"
MEM="$DIR/cerebro/memory"
PEND="$MEM/pendencias-dono.md"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$MEM" 2>/dev/null
{
  echo "# Checkpoint automático (hook Stop)"
  echo "Última atividade: $TS"
  echo
  echo "Ao acordar de restart/compactação: LEIA cerebro/memory/ (MEMORY.md, dono.md, loja.md, metas.md, pendencias-dono.md) ANTES de responder."
  if [ -f "$PEND" ]; then
    echo
    echo "## Snapshot pendências ABERTAS no último turn"
    awk '/## ABERTAS/{f=1;next} /## RESOLVIDAS/{f=0} f' "$PEND"
  fi
} > "$MEM/current-checkpoint.md" 2>/dev/null
exit 0
