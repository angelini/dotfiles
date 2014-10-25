#!/bin/bash

# DEV="1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ${DEV} ]
then
    HOME="${DIR}/dev"
fi

require () {
    if ! hash ${1} 2>/dev/null
    then
        echo 1>&2 "Missing requirement ${1}"
        exit 1
    fi
}

link () {
    TARGET="${HOME}/.${1}"

    if [ ! -f ${TARGET} ]
    then
        ln -s "${DIR}/${1}" "${TARGET}"
    fi
}

require "tmux"
require "zsh"
require "vim"
require "rbenv"

link "agignore"
link "emacs.el"
link "jshintrc"
link "gitconfig"
link "gitignore_global"
link "tmux.conf"
link "tmux-osx.conf"
link "tmux-linux.conf"
link "vimrc"
link "vim"
link "zshrc"
link "zpreztorc"

# Setup default shell
if [ ${SHELL} != "/bin/zsh" ]
then
    chsh -s /bin/zsh
fi

# Create directory for vundle to be cloned into
mkdir -p vim/bundle

# Update submodules
git submodule init 1>/dev/null
git submodule update 1>/dev/null

link "zprezto"

# Install vim plugins
vim +PluginInstall +qall

# Build matcher
cd matcher
make
sudo make install
cd ..
