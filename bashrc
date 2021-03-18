# Aliases
alias l="ls -hlAG"
alias gs="git status"
alias gc="git checkout"
alias ga="git commit --amend --no-edit"
alias gpo='git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gpfo='git push origin +$(git rev-parse --abbrev-ref HEAD)'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative --max-count=15"
alias rgc="rg -C 30"
alias epoch='python -c "import time; print(time.strftime(\"%Y-%m-%d %H:%M:%S\", time.localtime($@)))"'

if [[ -f "${HOME}/.aliases" ]]; then
  . "${HOME}/.aliases"
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:${PATH}"
export EDITOR=emacs

# Bash history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000000
export HISTFILESIZE=1000000

shopt -s histappend
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Emacs
export PATH="${HOME}/.cask/bin:${PATH}"

# Ruby
if hash rbenv 2> /dev/null; then
  export PATH="${HOME}/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi

# Python
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

if which pyenv > /dev/null; then
  eval "$(pyenv init -)";
  # eval "$(pyenv virtualenv-init -)"
fi

# Rust
if [[ -d "${HOME}/.cargo" ]]; then
  export PATH="${PATH}:${HOME}/.cargo/bin"
  source "$HOME/.cargo/env"
fi

# Golang
export GOPATH="${HOME}"
export GO111MODULE=on
export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Java
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 13`
fi

# Clojure
export LEIN_FAST_TRAMPOLINE=true
export LEIN_JVM_OPTS=-XX:TieredStopAtLevel=1  # Causes a performance degradation for long running processes

# C++
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

# Javascript
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && . "${NVM_DIR}/bash_completion"

# Lua
export PATH="${HOME}/.luarocks/bin:${PATH}"

# Postgres
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi

# MongoDB
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="/usr/local/opt/mongodb-community/bin:${PATH}"
fi

# Prompt
GIT_PROMPT_DIR="${HOME}/.bash-git-prompt"
if [[ -d "${GIT_PROMPT_DIR}" ]]; then
  GIT_PROMPT_START="\[\033[0;32m\]\h\[\033[0;0m\] \[\033[0;33m\]\w\[\033[0;0m\]"
  source "${GIT_PROMPT_DIR}/gitprompt.sh"
fi

# Bash completions
if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
  BASH_COMPLETION_FILE="/usr/share/bash-completion/bash_completion"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  BASH_COMPLETION_FILE="/usr/local/etc/bash_completion"
fi

if [[ -f "${HOME}/.git-completion.bash" ]]; then
  source "${HOME}/.git-completion.bash"
fi

if [[ -f "${BASH_COMPLETION_FILE}" ]]; then
  source "${BASH_COMPLETION_FILE}"
fi

# Google cloud SDK
GCP_SDK_DIR="${HOME}/google-cloud-sdk"
if [[ -d "${GCP_SDK_DIR}" ]]; then
  source "${GCP_SDK_DIR}/path.bash.inc"
  source "${GCP_SDK_DIR}/completion.bash.inc"
fi

# Postgres
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="${PATH}:/Applications/Postgres.app/Contents/Versions/latest/bin"
fi

# WSL
if [[ "${OSTYPE}" == "linux-gnu"* ]] && grep -q "Microsoft" /proc/sys/kernel/osrelease; then
  export DISPLAY=:0.0
fi

# Homebrew
export HOMEBREW_NO_ANALYTICS=1

# K8S
KUBE_CONFIG_DIR="${HOME}/.kube"
if [[ -d "${KUBE_CONFIG_DIR}" ]]; then
  export KUBECONFIG="${KUBE_CONFIG_DIR}/config:${KUBE_CONFIG_DIR}/eksconfig"
fi
