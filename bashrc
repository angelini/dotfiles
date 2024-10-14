#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

bin_exists() {
    type -t "${1}" &> /dev/null
}

export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:${PATH}"
export EDITOR=vim

if [[ -f "${HOME}/.aliases" ]]; then
    source "${HOME}/.aliases"
fi

# Bash history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000000
export HISTFILESIZE=1000000

shopt -s histappend
export PROMPT_COMMAND="history -a"

# Bash Completion
if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    source "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

# Clang
if bin_exists "clang"; then
    export CC="$(which clang)"
    export CXX="$(which clang++)"
fi

# Rust
if [[ -d "${HOME}/.cargo" ]]; then
    export PATH="${PATH}:${HOME}/.cargo/bin"
    source "${HOME}/.cargo/env"
fi

# Javascript
export NVM_DIR="${HOME}/.nvm"
if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    source "${NVM_DIR}/nvm.sh"
fi
if [[ -s "${NVM_DIR}/bash_completion" ]]; then
    source "${NVM_DIR}/bash_completion"
fi
if bin_exists "npm"; then
    export NODE_PATH="${NODE_PATH}:$(npm root -g)"
fi

# Lua
LUAROCKS_DIR="${HOME}/.luarocks"
if [[ -d "${LUAROCKS_DIR}" ]]; then
    export PATH="${LUAROCKS_DIR}/bin:${PATH}"
fi

# Google cloud SDK
GCP_SDK_DIR="${HOME}/google-cloud-sdk"
if [[ -d "${GCP_SDK_DIR}" ]]; then
    source "${GCP_SDK_DIR}/path.bash.inc"
    source "${GCP_SDK_DIR}/completion.bash.inc"
fi

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# K8S
KUBE_CONFIG_DIR="${HOME}/.kube"
if [[ -d "${KUBE_CONFIG_DIR}" ]]; then
    export KUBECONFIG="${KUBE_CONFIG_DIR}/config"
fi

# Starship
if bin_exists "starship"; then
    export STARSHIP_PREEXEC_READY=false
    eval "$(starship init bash)"
fi

# Deno
export DENO_INSTALL="${HOME}/.deno"
if [[ -d "${DENO_INSTALL}" ]]; then
    export PATH="${DENO_INSTALL}/bin:${PATH}"
fi

# Utility Functions
epoch() {
    local seconds="${1}"
    python -c "import time; print(time.strftime(\"%Y-%m-%d %H:%M:%S\", time.localtime(${seconds})))"
}
