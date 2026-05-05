#!/usr/bin/env bash
# Helpers de log/cor — reuso do setup-pulsar-os.sh original
# shellcheck disable=SC2034

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

step() { echo -e "${BLUE}${BOLD}>${NC} $*"; }
ok()   { echo -e "${GREEN}OK${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
err()  { echo -e "${RED}X${NC} $*" >&2; exit 1; }
info() { echo -e "  $*"; }
