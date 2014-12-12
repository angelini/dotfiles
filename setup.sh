#!/bin/bash

echo "* angelini/dotfiles"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "${DEV}" ]]; then
  echo "= DEV"
  HOME="${DIR}/dev"
fi

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  echo "= linux"
  UPDATE="sudo apt-get update"
  INSTALL="sudo apt-get install -y"
  CHECK="dpkg -s"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  echo "= osx"
  UPDATE="brew update"
  INSTALL="brew install"
  CHECK="brew ls --versions"

  if ! hash brew 2> /dev/null; then
    echo "- installing brew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 1> /dev/null
  fi
fi

link () {
  TARGET="${HOME}/.${1}"

  if [[ ! -f "${TARGET}" ]]; then
    echo "- linking ${TARGET}"
    ln -s "${DIR}/${1}" "${TARGET}"
  fi
}

update() {
  echo "- updating"
  ${UPDATE} 1> /dev/null
}

install() {
  PACKAGE="${1}"

  if ! ${CHECK} "${PACKAGE}" &> /dev/null; then
    echo "- installing ${PACKAGE}"
    ${INSTALL} "${PACKAGE}" > /dev/null
  fi
}

pip_install() {
  MODULE="${1}"

  if [[ -z "$(pip show ${MODULE})" ]]; then
    echo "- pip installing ${MODULE}"
    pip install "${MODULE}" > /dev/null
  fi
}

install_pip() {
  if hash pip 2> /dev/null; then
    echo "- installing pip"
    curl -O -s https://bootstrap.pypa.io/get-pip.py
    python get-pip.py > /dev/null
    rm get-pip.py
  fi
}

echo "= emacs-config"
EMACS_DIR="${DIR}/../emacs-config"

if [[ ! -d "${EMACS_DIR}" ]]; then
  echo "- cloning"
  git clone git@github.com:angelini/emacs-config.git "${EMACS_DIR}" > /dev/null
  echo "- linking"
  ln -s "${EMACS_DIR}" "${HOME}/.emacs.d"
fi

echo "= bash-git-prompt"

if [[ ! -d "./bash-git-prompt" ]]; then
  echo "- cloning"
  git clone -q https://github.com/magicmonty/bash-git-prompt.git
  link "bash-git-prompt"
fi

echo "= python"
install_pip
pip_install "virtualenv"
pip_install "virtualenvwrapper"

echo "= dotfiles"
link "profile"
link "agignore"
link "flake8.rc"
link "jshintrc"

link "gitconfig"
link "gitignore_global"

link "tmux.conf"
link "tmux-osx.conf"
link "tmux-linux.conf"

echo "= installer"
update
install "rbenv"
install "ruby-build"
install "bash-completion"
install "tree"

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  install "emacs24-nox"
  install "silversearcher-ag"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  install "emacs"
  install "the_silver_searcher"
  install "reattach-to-user-namespace"
fi
