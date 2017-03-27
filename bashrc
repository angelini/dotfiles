# Aliases
alias l="ls --color -hlAG"
alias gs="git status"
alias gc="git checkout"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative"
alias cs="cd ~/src/starscream"
alias knife="BUNDLE_GEMFILE=/Users/alexangelini/.chef/Gemfile bundle exec knife"

export PATH="${HOME}/bin:/usr/local/bin:${PATH}"
export EDITOR=emacs

if [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi

# Bash history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000000
export HISTFILESIZE=1000000

shopt -s histappend
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Ruby
export PATH="${HOME}/.rbenv/bin:${PATH}"
if hash rbenv 2> /dev/null; then
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
export RUST_SRC_PATH="${HOME}/src/rustc-1.5.0/src"
export PATH="${PATH}:${HOME}/.cargo/bin"

# Golang
export GOROOT="${HOME}/packages/go"
export GOPATH="${HOME}/go"
export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Java
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_31`
fi

# Clojure
export LEIN_FAST_TRAMPOLINE=true
export LEIN_JVM_OPTS=-XX:TieredStopAtLevel=1  # Causes a performance degradation for long running processes

# Shopify
export IM_ALREADY_PRO_THANKS=true
export NO_AUTOAUTOLINT=true

# Hadoop
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export HADOOP_CONF_DIR="${HOME}/src/starscream/.cache/spark/current/conf/conf.cloudera.yarn"
  export HADOOP_HOME="/usr/local/Cellar/hadoop/2.7.1"
  export HIVE_HOME="/usr/local/Cellar/hive/1.2.1/libexec"
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

export NVM_DIR="/Users/alexangelini/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$HOME/.cargo/bin:$PATH"

# Google cloud SDK
source "${HOME}/google-cloud-sdk/path.bash.inc"
source "${HOME}/google-cloud-sdk/completion.bash.inc"
