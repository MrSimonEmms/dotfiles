#!/bin/bash

set -euo pipefail

function bash_alias() {
  echo "Setting up bash_alias"

  cp "${HOME}/.dotfiles/.bash_aliases" "${HOME}/.bash_aliases"
}

function kubeconfig() {
  echo "Looking for a KUBECONFIG_BASE64 envvar"

  if [ -n "${KUBECONFIG_BASE64-}" ]; then
    echo "KUBECONFIG_BASE64 envvar found"

    KUBECONFIG="${HOME}/.kube/config"

    mkdir -p "${HOME}/.kube"
    mv -f "${KUBECONFIG}" "${HOME}/.kube/config.orig" || true # Save the old kubeconfig
    echo "${KUBECONFIG_BASE64}" | base64 -d > "${KUBECONFIG}"
    chmod 600 "${KUBECONFIG}"
  fi
}

function ohmyzsh() {
  echo "Installing Oh My ZSH!"

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  PID_FILE="${HOME}/.oh-my-zsh/store.pid"

  # Kill the old PID if it's running
  OLD_PID=$(cat "${PID_FILE}" || true)
  if [ "${OLD_PID}" != "" ]; then
    echo "Killing PID: ${OLD_PID}"
    kill $(cat "${PID_FILE}") || true
  fi

  # Start backup process
  bash ./ohmyzsh_backup.sh &

  # Get the PID and store it so we can run this again
  PID=$!
  echo "Backup PID: ${PID}"
  echo "${PID}" > "${PID_FILE}"
}

kubeconfig
ohmyzsh
bash_alias
