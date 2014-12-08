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

PATH="${HOME}/bin:${PATH}"

# Ruby
export PATH="${HOME}/.rbenv/bin:${PATH}"
if hash rbenv 2> /dev/null; then
  eval "$(rbenv init -)"
fi

# Python
export WORKON_HOME="~/.virtualenvs"
if hash brew 2> /dev/null; then
  source "$(brew --prefix)/bin/virtualenvwrapper.sh"
fi

# Golang
export GOPATH="${HOME}/.go"

# Shopify
export IM_ALREADY_PRO_THANKS=true
export NO_AUTOLINT=true

# Prompt
GIT_PROMPT_DIR="${HOME}/.bash-git-prompt"
if [[ -d "${GIT_PROMPT_DIR}" ]]; then
  source "${GIT_PROMPT_DIR}/gitprompt.sh"
fi

# Bash completions
BASH_COMPLETION="/usr/share/bash-completion/bash_completion"
if [[ -f "${BASH_COMPLETION}" ]]; then
  source "${BASH_COMPLETION}"
fi

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  export PATH="/opt/emacs/bin:${PATH}"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi
