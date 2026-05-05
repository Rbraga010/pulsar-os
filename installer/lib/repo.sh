#!/usr/bin/env bash
# Clone do repo Pulsar OS no diretorio atual

PULSAR_OS_REPO="${PULSAR_OS_REPO_URL:-${PULSAR_OS_REPO:-https://github.com/pulsarh-ai/pulsar-os.git}}"
PULSAR_OS_BRANCH="${PULSAR_OS_BRANCH:-main}"

clone_repo() {
  if state_done "repo_clone"; then ok "Repo ja clonado"; return; fi
  step "[3/8] Clonando repo Pulsar OS"

  local target="${PULSAR_OS_HOME:-$PWD}"
  if [[ -d "${target}/.git" ]]; then
    info "Repo ja existe em ${target} — fazendo pull"
    git -C "${target}" pull --ff-only origin "${PULSAR_OS_BRANCH}" || warn "pull falhou (ignorando)"
  else
    git clone --depth 1 --branch "${PULSAR_OS_BRANCH}" "${PULSAR_OS_REPO}" "${target}"
  fi

  # Forca git config user.email pro email Vercel correto (memoria feedback_vercel_commit_author_email)
  if [[ -n "${PULSAR_VERCEL_EMAIL:-}" ]]; then
    git -C "${target}" config user.email "${PULSAR_VERCEL_EMAIL}"
    git -C "${target}" config user.name "${PULSAR_TENANT_NAME:-Pulsar OS Founder}"
    ok "git user.email = ${PULSAR_VERCEL_EMAIL}"
  fi

  ok "Repo em ${target}"
  state_mark "repo_clone"
}
