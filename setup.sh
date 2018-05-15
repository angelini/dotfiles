#!/usr/bin/env bash

echo "* angelini/dotfiles"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "${DEV}" ]]; then
    echo "* DEV"
    HOME="${DIR}/dev"
fi

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
    echo "* linux"
    UPDATE="sudo yaourt -Syu --noconfirm"
    INSTALL="sudo yaourt -Sy --noconfirm"
    CHECK="yaourt -Qs"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "* osx"
    UPDATE="brew update"
    INSTALL="brew install"
    CHECK="brew ls --versions"
    if ! hash brew 2> /dev/null; then
        echo "- installing brew"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 1> /dev/null
    fi
fi

link () {
    local target="${DIR}/${1}"
    local link="${HOME}/.${2:-$1}"
    if [[ ! -e "${link}" ]]; then
        echo "- linking ${target} to ${link}"
        ln -s "${target}" "${link}"
    fi
}

link_config() {
    link "arch/${1}" "config/${1}"
}

install() {
    local package="${1}"
    if ! ${CHECK} "${package}" &> /dev/null; then
        echo "- installing ${package}"
        if [[ "${2}" ]]; then
            yaourt -Sy --noconfirm "${package}" > /dev/null
        else
            ${INSTALL} "${package}" > /dev/null
        fi
    fi
}

install_pyenv() {
    local pyenv_dir="${HOME}/.pyenv"
    if ! hash pyenv 2> /dev/null; then
        echo "- installing pyenv"
        git clone -q https://github.com/yyuu/pyenv.git "${pyenv_dir}"
        git clone -q https://github.com/yyuu/pyenv-virtualenv.git "${pyenv_dir}/plugins/pyenv-virtualenv"
    fi
}

install_bash_git_prompt() {
    if [[ ! -d "./bash-git-prompt" ]]; then
        echo "- installing bash-git-prompt"
        git clone -q https://github.com/magicmonty/bash-git-prompt.git
    fi
    link "bash-git-prompt"

    if [[ ! -f "./git-completion.bash" ]]; then
        echo "- installing git-bash-completion"
        curl -O -sSf https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
    fi
    link "git-completion.bash"
}

install_rustup() {
    if ! hash rustc 2> /dev/null; then
        curl -sSf https://sh.rustup.rs > /tmp/rustup_install
        source /tmp/rustup_install
    fi
}

install_cask() {
    if ! hash cask 2> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
    fi
}

echo "= updating"
${UPDATE}

echo "= dotfiles"
link "bashrc"
source "${HOME}/.bashrc"
link "agignore"
link "flake8rc"
link "gitconfig"
link "gitignore_global"
link "tmux.conf"
link "tmux-osx.conf"
link "tmux-linux.conf"

echo "= base"
install "tree"
install "bash-completion"
install "emacs"
install "ripgrep"
install "fd"
install_bash_git_prompt

echo "= ruby"
install "rbenv" 1
install "ruby-build" 1

echo "= python"
install_pyenv

echo "= rust"
install_rustup

echo "= cask"
install_cask

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
    echo "= arch configs"
    link_config "dunst"
    link_config "fontconfig"
    link_config "i3"
    link_config "i3status"
    link_config "termite"
fi

echo "= emacs-config"
EMACS_DIR="${DIR}/../emacs-config"

if [[ ! -d "${EMACS_DIR}" ]]; then
  echo "- cloning"
  git clone -q git@github.com:angelini/emacs-config.git "${EMACS_DIR}" > /dev/null
  ln -s "${EMACS_DIR}" "${HOME}/.emacs.d"
fi
link "../emacs-config" "emacs.d"
