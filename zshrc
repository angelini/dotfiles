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
alias gs="git status"
alias gc="git checkout"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %Creset%Cblue%an%Creset %s %Cgreen(%cr)%Cred%d%Creset' --abbrev-commit --date=relative"
alias bx="bundle exec"
alias vs="cd ~/src/vagrant && vagrant ssh"

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
export PATH="/Applications/Postgres93.app/Contents/MacOS/bin:$PATH"

# Lineman
export LINEMAN_AUTO_START=false
export LINEMAN_AUTO_WATCH=false

# History
setopt inc_append_history
setopt share_history
