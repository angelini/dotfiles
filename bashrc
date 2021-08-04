#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

bin_exists() {
    type -t "${1}" &> /dev/null
}

detect_os() {
    if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "${OSTYPE}" == "darwin" ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

is_wsl() {
    if [[ "$(detect_os)" == "linux" ]]; then
        grep -q "microsoft" "/proc/sys/kernel/osrelease"
    else
        return 1
    fi
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

# SSH-agent
if bin_exists "keychain"; then
    eval "$(keychain --eval id_ed25519)"
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

# Clang
if bin_exists "clang"; then
    export CC="/usr/bin/clang"
    export CXX="/usr/bin/clang++"
fi

# Python
if [[ -d "${HOME}/.pyenv" ]]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"
    eval "$(pyenv init -)"
fi

# Ruby
if bin_exists "rbenv"; then
  export PATH="${HOME}/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi

# Rust
if [[ -d "${HOME}/.cargo" ]]; then
    export PATH="${PATH}:${HOME}/.cargo/bin"
    source "${HOME}/.cargo/env"
fi

# Golang
export GOROOT="/usr/local/go"
export PATH="${PATH}:${GOROOT}/bin"
if bin_exists "go"; then
    export GOPATH="${HOME}"
    export GO111MODULE=on
fi

# Java
if [[ -d "/usr/lib/jvm/java-11" ]]; then
    export JAVA_HOME="/usr/lib/jvm/java-11"
fi

# Javascript
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"

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

# WSL
if is_wsl; then
    export DISPLAY=:0.0
fi

# Homebrew
export HOMEBREW_NO_ANALYTICS=1

# K8S
KUBE_CONFIG_DIR="${HOME}/.kube"
if [[ -d "${KUBE_CONFIG_DIR}" ]]; then
    export KUBECONFIG="${KUBE_CONFIG_DIR}/config"
fi

# Fedora Server
if [[ "$(hostname)" == "fedora-server" ]]; then
    export LIBVIRT_DEFAULT_URI="qemu:///system"
    export GDK_SCALE=2
fi

# Starship
if bin_exists "starship"; then
    export STARSHIP_PREEXEC_READY=false
    eval "$(starship init bash)"
fi

# Mkcert
if bin_exists "mkcert"; then
    export NODE_EXTRA_CA_CERTS="$(mkcert -CAROOT)/rootCA.pem"
fi

# Utility Functions
epoch() {
    local seconds="${1}"
    python -c "import time; print(time.strftime(\"%Y-%m-%d %H:%M:%S\", time.localtime(${seconds})))"
}
