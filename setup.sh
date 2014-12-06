#!/bin/bash

echo "= angelini/dotfiles"
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
elif [[ "${OSTYPE}" == "darwin" ]]; then
  echo "= osx"
  UPDATE="brew update"
  INSTALL="brew install"
  CHECK="brew ls --versions"

  if hash brew 2> /dev/null; then
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

  if ! ${CHECK} "${PACKAGE}" > /dev/null 2>&1; then
      echo "- installing ${PACKAGE}"
      ${INSTALL} "${PACKAGE}" 1> /dev/null
  fi
}

install_emacs_source() {
  TARGET="${1}"

  if [[ ! -d "${TARGET}" ]]; then
    echo "- installing emacs (from source)"
    echo "-- installing deps"
    sudo apt-get install -y build-essential 1> /dev/null
    sudo apt-get build-dep -y emacs24 1> /dev/null

    echo "-- fetching source"
    curl -O -s http://ftp.gnu.org/gnu/emacs/emacs-24.4.tar.gz
    tar -xzvf emacs-24.4.tar.gz
    rm emacs-24.4.tar.gz

    cd emacs-24.4

    echo "-- configuring"
    ./configure --prefix=/opt/emacs 1> /dev/null

    echo "-- compiling"
    make 1> /dev/null
    sudo make install 1> /dev/null

    cd ..
  fi
}

echo "= emacs-config"
EMACS_DIR="${DIR}/../emacs-config"

if [[ ! -d "${EMACS_DIR}" ]]; then
  echo "- cloning"
  git clone git@github.com:angelini/emacs-config.git "${EMACS_DIR}" 1> /dev/null
  echo "- linking"
  ln -s "${EMACS_DIR}" "${HOME}/.emacs.d"
fi

echo "= bash-git-prompt"

if [[ ! -d "./bash-git-prompt" ]]; then
  echo "- cloning"
  git clone -q https://github.com/magicmonty/bash-git-prompt.git
  link "bash-git-prompt"
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

echo "= installer"
update
install "silversearcher-ag"
install "rbenv"
install "ruby-build"
install "bash-completion"
install "tree"

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  install_emacs_source "/opt/emacs"
elif [[ "${OSTYPE}" == "darwin" ]]; then
  install "emacs"
  install "reattach-to-user-namespace"
fi
