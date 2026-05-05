#!/usr/bin/env bash
# State machine simples — rastreia o que ja foi feito pra idempotencia
# Usa $STATE_FILE (touch'ado pelo install.sh)

state_done() {
  local key="$1"
  grep -qxF "${key}" "${STATE_FILE}" 2>/dev/null
}

state_mark() {
  local key="$1"
  state_done "${key}" || echo "${key}" >> "${STATE_FILE}"
}

state_clear() {
  : > "${STATE_FILE}"
}
