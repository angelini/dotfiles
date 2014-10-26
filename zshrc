# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Vi Mode
bindkey -v
bindkey '^r' history-incremental-search-backward

export KEYTIMEOUT=1

# Aliases
alias l="ls -A"
alias gs="git status -uno"
alias gc="git checkout"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative"
alias bx="bundle exec"
alias bs="bundle exec spring"
alias bt="bundle exec spring testunit"
alias vs="cd ~/src/vagrant && vagrant ssh"
alias cs="cd ~/src/shopify"
alias ac="ag -G coffee"
alias ar="ag -G rb"

# OSX Vim alias
if [[ $( uname ) == "Darwin" ]]; then
    alias vim="mvim -v"
fi

alias vi="vim"

bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

unset BROWSER

# Rbenv
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# Postgres.app
export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:$PATH"

# Lineman
export LINEMAN_AUTO_START=false
export LINEMAN_AUTO_WATCH=false

# Golang
export GOPATH=$HOME/.go

# Python
export WORKON_HOME=~/.virtualenvs
if hash brew 2>/dev/null
then
    source $(brew --prefix)/bin/virtualenvwrapper.sh
fi

# History
setopt inc_append_history
setopt share_history

# Shopify
export IM_ALREADY_PRO_THANKS=true
