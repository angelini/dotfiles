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
link "gitignore"
link "jshintrc"
link "gitignore_global"
link "tmux.conf"
link "vimrc"
link "vim"
link "zshrc"
link "zpreztorc"

# Setup default shell
if [ ${SHELL} != "/bin/zsh" ]
then
    echo "Set default shell: sudo chsh -s /bin/zsh"
fi

# Install vim plugins
vim +BundleInstall +qall

# Update submodules
git submodule init
git submodule update

link "zprezto"
