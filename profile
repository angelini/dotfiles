# Aliases
alias l="ls -A"
alias gs="git status"
alias gc="git checkout"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative"
alias bx="bundle exec"
alias bs="bundle exec spring"
alias bt="bundle exec spring testunit"
alias vs="cd ~/src/vagrant && vagrant ssh"
alias cs="cd ~/src/starscream"

export PATH="${HOME}/bin:/usr/local/bin:${PATH}"
export EDITOR=emacs

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  PREFIX="/usr/share"
  export PATH="/opt/emacs/bin:${PATH}"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  PREFIX="/usr/local"
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi

# Bash history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
shopt -s histappend

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Ruby
export PATH="${HOME}/.rbenv/bin:${PATH}"
if hash rbenv 2> /dev/null; then
  eval "$(rbenv init -)"
fi

# Python
export WORKON_HOME="~/.virtualenvs"
if hash brew 2> /dev/null; then
  source "${PREFIX}/bin/virtualenvwrapper.sh"
fi

# Golang
export GOPATH="${HOME}/.go"

# Shopify
export IM_ALREADY_PRO_THANKS=true
export NO_AUTOAUTOLINT=true

# Prompt
GIT_PROMPT_DIR="${HOME}/.bash-git-prompt"

if [[ -d "${GIT_PROMPT_DIR}" ]]; then
  source "${GIT_PROMPT_DIR}/gitprompt.sh"
fi

# Bash completions
if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  BASH_COMPLETION_FILE="${PREFIX}/bash-completion/bash_completion"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  BASH_COMPLETION_FILE="${PREFIX}/etc/bash_completion"
fi

if [[ -f "${BASH_COMPLETION_FILE}" ]]; then
  source "${BASH_COMPLETION_FILE}"
fi
