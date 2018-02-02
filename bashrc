# Aliases
alias l="ls --color -hlAG"
alias gs="git status"
alias gc="git checkout"
alias gn="git commit --amend --no-edit"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative"
alias cs="cd ~/src/starscream"

export PATH="${HOME}/bin:/usr/local/bin:${PATH}"
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

if which pyenv > /dev/null; then
   eval "$(pyenv init -)";
   eval "$(pyenv virtualenv-init -)"
fi

# Rust
export PATH="${PATH}:${HOME}/.cargo/bin"

# Golang
export GOROOT="${HOME}/packages/go"
export GOPATH="${HOME}/go"
export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Java
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
fi

# Clojure
export LEIN_FAST_TRAMPOLINE=true
export LEIN_JVM_OPTS=-XX:TieredStopAtLevel=1  # Causes a performance degradation for long running processes

# Rust
export PATH="${HOME}/.cargo/bin:${PATH}"

# Shopify
export IM_ALREADY_PRO_THANKS=true
export NO_AUTOAUTOLINT=true

# Hadoop
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export HADOOP_CONF_DIR="${HOME}/src/starscream/.cache/spark/current/conf/conf.cloudera.yarn"
  export HADOOP_HOME="/usr/local/Cellar/hadoop/2.7.1"
  export HIVE_HOME="/usr/local/Cellar/hive/1.2.1/libexec"
fi

# Postgres
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi

# Prompt
GIT_PROMPT_DIR="${HOME}/.bash-git-prompt"
if [[ -d "${GIT_PROMPT_DIR}" ]]; then
  source "${GIT_PROMPT_DIR}/gitprompt.sh"
fi

# Bash completions
if [[ "${OSTYPE}" == "linux-gnu" ]]; then
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
if [[ "${OSTYPE}" == "darwin"* ]]; then
  source "${HOME}/google-cloud-sdk/path.bash.inc"
  source "${HOME}/google-cloud-sdk/completion.bash.inc"
fi
