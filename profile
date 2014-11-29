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

if [[ "${OSTYPE}" == "darwin" ]]; then
  # Postgres.app
  export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:${PATH}"
fi
