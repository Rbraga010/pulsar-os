#!/usr/bin/env bash
# Wrappers de prompt interativo (idempotentes)

ask() {
  local prompt="$1"
  local default="${2:-}"
  local var_name="$3"
  local value
  if [[ -n "${default}" ]]; then
    read -r -p "  ${prompt} [${default}]: " value
    value="${value:-$default}"
  else
    read -r -p "  ${prompt}: " value
  fi
  printf -v "${var_name}" '%s' "${value}"
  export "${var_name?}"
}

ask_secret() {
  local prompt="$1"
  local var_name="$2"
  local value
  read -r -s -p "  ${prompt}: " value
  echo
  printf -v "${var_name}" '%s' "${value}"
  export "${var_name?}"
}

ask_yn() {
  local prompt="$1"
  local default="${2:-n}"
  local answer
  read -r -p "  ${prompt} [${default}]: " answer
  answer="${answer:-$default}"
  [[ "${answer,,}" == "y" || "${answer,,}" == "yes" || "${answer,,}" == "s" || "${answer,,}" == "sim" ]]
}
