#!/usr/bin/env bash
#
# Pulsar OS — build.sh
# Empacota o zip único distribuível (DIY R$297). Sem variantes.
# Order bump R$1.297 é checkout-side, não muda o conteúdo.
# Idempotente: rodar 2x produz mesmo resultado.
#
# Uso:
#   bash build.sh                          # default v1.0.0, output dist/
#   bash build.sh --version v1.0.1
#   bash build.sh --output /tmp/release/
#   bash build.sh --dry-run                # só lista, não zipa
#
set -euo pipefail

# ----------------------------------------------------------------------------
# Args
# ----------------------------------------------------------------------------
VERSION="v1.0.0"
OUTPUT_DIR=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)  VERSION="$2"; shift 2;;
    --output)   OUTPUT_DIR="$2"; shift 2;;
    --dry-run)  DRY_RUN=1; shift;;
    -h|--help)
      sed -n '2,15p' "$0"; exit 0;;
    *) echo "arg desconhecido: $1"; exit 1;;
  esac
done

# ----------------------------------------------------------------------------
# Paths
# ----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "${SCRIPT_DIR}/.." && pwd)"        # /root/pulsarh-workspace/pulsar-os
ROOT="$(cd "${WORKSPACE}/.." && pwd)"              # /root/pulsarh-workspace
BRAND_SRC="${ROOT}/brand/v1.0-half-light"
TEMPLATES="${SCRIPT_DIR}/templates"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRIPT_DIR}}"

STAGE="${OUTPUT_DIR}/build"
PKG_NAME="pulsar-os-${VERSION}"
PKG_DIR="${STAGE}/${PKG_NAME}"
ZIP_PATH="${OUTPUT_DIR}/${PKG_NAME}.zip"
SHA_PATH="${OUTPUT_DIR}/${PKG_NAME}.sha256"

# ----------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------
log()  { printf "\033[2m[%s]\033[0m %s\n" "$(date +%H:%M:%S)" "$*"; }
warn() { printf "\033[33m[warn]\033[0m %s\n" "$*"; }
die()  { printf "\033[31m[erro]\033[0m %s\n" "$*"; exit 1; }

# ----------------------------------------------------------------------------
# Preflight
# ----------------------------------------------------------------------------
preflight() {
  command -v zip       >/dev/null || die "zip não instalado (apt install zip)"
  command -v sha256sum >/dev/null || die "sha256sum não disponível"
  command -v rsync     >/dev/null || die "rsync não disponível"
  [[ -d "${WORKSPACE}/installer" ]]            || die "installer/ ausente em ${WORKSPACE}"
  [[ -f "${WORKSPACE}/CLAUDE.md.template" ]]   || die "CLAUDE.md.template ausente"
  [[ -f "${WORKSPACE}/bootstrap/PROMPT.md" ]]  || die "bootstrap/PROMPT.md ausente"
  [[ -d "${BRAND_SRC}" ]]                      || die "brand v1.0 ausente em ${BRAND_SRC}"
  [[ -f "${TEMPLATES}/README.md" ]]            || die "templates/README.md ausente"
  [[ -f "${TEMPLATES}/LICENSE.md" ]]           || die "templates/LICENSE.md ausente"
  [[ -f "${TEMPLATES}/BOOTSTRAP-PROMPT.md" ]]  || die "templates/BOOTSTRAP-PROMPT.md ausente"
  [[ -f "${TEMPLATES}/VERSION" ]]              || die "templates/VERSION ausente"
  [[ -f "${TEMPLATES}/tenant-readme.md" ]]     || die "templates/tenant-readme.md ausente"
  [[ -f "${TEMPLATES}/GARANTIA.md" ]]           || die "templates/GARANTIA.md ausente"
  [[ -f "${TEMPLATES}/JORNADA.md" ]]            || die "templates/JORNADA.md ausente"
  log "preflight ok"
}

# ----------------------------------------------------------------------------
# Stage
# ----------------------------------------------------------------------------
build_stage() {
  log "limpando stage anterior"
  rm -rf "${STAGE}"
  mkdir -p "${PKG_DIR}"

  log "copiando core/"
  mkdir -p "${PKG_DIR}/core"
  cp    "${WORKSPACE}/CLAUDE.md.template"            "${PKG_DIR}/core/"
  cp    "${WORKSPACE}/agents-config.default.json"    "${PKG_DIR}/core/"
  cp    "${WORKSPACE}/agents-config.schema.json"     "${PKG_DIR}/core/"
  cp -r "${WORKSPACE}/agents-template"               "${PKG_DIR}/core/"
  cp -r "${WORKSPACE}/skills-template"               "${PKG_DIR}/core/"
  cp -r "${WORKSPACE}/onboarding"                    "${PKG_DIR}/core/"
  cp -r "${WORKSPACE}/bootstrap"                     "${PKG_DIR}/core/"
  cp -r "${BRAND_SRC}"                               "${PKG_DIR}/core/brand"

  log "copiando installer/ (excluindo docs internas)"
  mkdir -p "${PKG_DIR}/installer"
  rsync -a \
    --exclude='AUDIT-existing-script.md' \
    --exclude='VALIDATION.md' \
    --exclude='handoff-to-3.md' \
    --exclude='handoff-*.md' \
    --exclude='*.log' \
    --exclude='.env' \
    "${WORKSPACE}/installer/" "${PKG_DIR}/installer/"

  log "criando tenant/ vazio"
  mkdir -p "${PKG_DIR}/tenant"
  touch "${PKG_DIR}/tenant/.gitkeep"
  cp "${TEMPLATES}/tenant-readme.md" "${PKG_DIR}/tenant/README.md"

  log "copiando arquivos raiz (README, LICENSE, BOOTSTRAP-PROMPT, VERSION)"
  cp "${TEMPLATES}/README.md"             "${PKG_DIR}/README.md"
  cp "${TEMPLATES}/LICENSE.md"            "${PKG_DIR}/LICENSE.md"
  cp "${TEMPLATES}/BOOTSTRAP-PROMPT.md"   "${PKG_DIR}/BOOTSTRAP-PROMPT.md"
  cp "${TEMPLATES}/VERSION"               "${PKG_DIR}/VERSION"
  cp "${TEMPLATES}/GARANTIA.md"          "${PKG_DIR}/GARANTIA.md"
  mkdir -p "${PKG_DIR}/docs"
  cp "${TEMPLATES}/JORNADA.md"           "${PKG_DIR}/docs/JORNADA.md"
}

# ----------------------------------------------------------------------------
# Pack
# ----------------------------------------------------------------------------
pack() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    local count size
    count=$(find "${PKG_DIR}" -type f | wc -l)
    size=$(du -sh "${PKG_DIR}" | awk '{print $1}')
    log "DRY-RUN: ${count} arquivos, ${size} descompactado → ${ZIP_PATH}"
    return 0
  fi

  log "empacotando → ${ZIP_PATH}"
  rm -f "${ZIP_PATH}"
  ( cd "${STAGE}" && zip -qr "${ZIP_PATH}" "${PKG_NAME}" )

  log "gerando sha256"
  ( cd "${OUTPUT_DIR}" && sha256sum "$(basename "${ZIP_PATH}")" > "$(basename "${SHA_PATH}")" )

  local zsize
  zsize=$(du -h "${ZIP_PATH}" | awk '{print $1}')
  log "  ${zsize}  ${ZIP_PATH}"
  log "  $(cat "${SHA_PATH}")"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------
main() {
  log "Pulsar OS build — versão ${VERSION}"
  log "  workspace: ${WORKSPACE}"
  log "  output:    ${OUTPUT_DIR}"
  [[ "${DRY_RUN}" -eq 1 ]] && log "  modo:      DRY-RUN"

  preflight
  build_stage
  pack

  if [[ "${DRY_RUN}" -eq 0 ]]; then
    log "limpando stage"
    rm -rf "${STAGE}"
  fi

  log "build concluído"
}

main "$@"
