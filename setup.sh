#!/bin/bash

echo "= angelini/dotfiles"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "${DEV}" ]]; then
  echo "= DEV"
  HOME="${DIR}/dev"
fi

link () {
  TARGET="${HOME}/.${1}"

  if [[ ! -f "${TARGET}" ]]; then
    echo "- linking ${TARGET}"
    ln -s "${DIR}/${1}" "${TARGET}"
  fi
}

install() {
  INSTALLER="${1}"
  EXECUTABLE="${2}"
  [[ -n "${3}" ]] && PACKAGE="${3}" || PACKAGE="${2}"

  if ! hash "${EXECUTABLE}" 2> /dev/null; then
      echo "- installing ${EXECUTABLE}"
      ${INSTALLER} "${PACKAGE}" 1> /dev/null
  fi
}

linux_install() {
  install "sudo apt-get install -y" "${1}" "${2}"
}

osx_install() {
  install "brew install" "${1}" "${2}"
}

# Install emacs-config
echo "= emacs-config"
EMACS_DIR="${DIR}/../emacs-config"

if [[ ! -d "${EMACS_DIR}" ]]; then
  echo "- cloning"
  git clone git@github.com:angelini/emacs-config.git "${EMACS_DIR}" 1> /dev/null
  echo "- linking"
  ln -s "${EMACS_DIR}" "${HOME}/.emacs.d"
fi

echo "= dotfiles"
link "profile"
link "agignore"
link "jshintrc"

link "gitconfig"
link "gitignore_global"

link "tmux.conf"
link "tmux-osx.conf"
link "tmux-linux.conf"

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  echo "= linux"
  echo "- updating"
  sudo apt-get update 1> /dev/null

  linux_install "ag" "silversearcher-ag"
  linux_install "emacs"
  linux_install "rbenv"
  linux_install "rbenv" "ruby-build"
fi

if [[ "${OSTYPE}" == "darwin" ]]; then
  echo "= osx"

  if hash brew 2> /dev/null; then
    echo "- installing brew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 1> /dev/null
  fi

  echo "-updating"
  brew update 1> /dev/null

  osx_install "ag"
  osx_install "emacs"
fi
