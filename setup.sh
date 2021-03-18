#!/usr/bin/env bash

echo "* angelini/dotfiles"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "${DEV}" ]]; then
  echo "* DEV"
  set -x
  HOME="${DIR}/dev"
fi

command_exists() {
  hash "${1}" 2> /dev/null
}

if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
  echo "= linux"
  if command_exists "apt-get"; then
    echo "- ubuntu"
    DISTRO="ubuntu"
    UPDATE="sudo apt-get update -y"
    INSTALL="sudo apt-get install -y"
    CHECK="dpkg -l"
  fi
  if command_exists "pacman"; then
    echo "- arch"
    DISTRO="arch"
    UPDATE="sudo yaourt -Syu --noconfirm"
    INSTALL="sudo yaourt -Sy --noconfirm"
    CHECK="yaourt -Qi"
    if ! command_exists "yaourt"; then
      sudo cat <<EOT >> /etc/pacman.conf
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch
EOT
      sudo pacman -Syu --noconfirm yaourt
    fi
  fi
  if command_exists "dnf"; then
    echo "-fedora"
    DISTRO="fedora"
    UPDATE="sudo dnf update -y"
    INSTALL="sudo dnf install -y"
    CHECK="dnf list installed"
  fi
  if [[ -z "${UPDATE}" ]]; then
	echo "unable to detect version of linux"
	exit 1
  fi
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  echo "= osx"
  DISTRO="macos"
  UPDATE="brew update"
  INSTALL="brew install"
  CHECK="brew ls --versions"
  if ! command_exists "brew"; then
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

link_bin() {
  local target="${1}"
  local link="${HOME}/bin/${2}"
  if [[ ! -e "${link}" ]]; then
    echo "-linking ${target} to ${link}"
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
    ${INSTALL} "${package}" > /dev/null
  fi
}

install_pyenv() {
  local pyenv_dir="${HOME}/.pyenv"
  if ! command_exists "pyenv"; then
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
    curl -O -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  fi
  link "git-completion.bash"
}

install_rustup() {
  if ! command_exists "rustc"; then
    curl -fsSL https://sh.rustup.rs > /tmp/rustup_install
    source /tmp/rustup_install -y
  fi
}

install_nvm() {
  if ! command_exists "nvm"; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  fi
}

install_cask() {
  if ! command_exists "cask"; then
    curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
  fi
}

echo "= updating"
${UPDATE}
mkdir -p "${HOME}/bin"

if [[ "${DISTRO}" == "ubuntu" ]]; then
  echo "= ubuntu specific"
  rm "${HOME}/.bashrc"
  install "apt-utils"
  install "curl"
fi

if [[ "${DISTRO}" == "arch" ]]; then
  echo "= arch specific"
  link_config "dunst"
  link_config "fontconfig"
  link_config "i3"
  link_config "i3status"
  link_config "termite"
fi

if [[ "${DISTRO}" == "fedora" ]]; then
  echo "= fedora specific"
  rm "${HOME}/.bashrc"
  install "libffi-devel"
  install "zlib-devel"
  install "bzip2-devel"
  install "sqlite-devel"
  install "openssl-devel"
  install "xz-devel"
  install "findutils"
fi

echo "= dotfiles"
link "bashrc"
source "${HOME}/.bashrc"
link "agignore"
link "flake8"
link "gitconfig"
link "gitignore_global"
link "tmux.conf"
link "tmux-osx.conf"
link "tmux-linux.conf"

echo "= base"
install "curl"
install "tree"
install "bash-completion"
install "emacs"
install "ripgrep"

if [[ "${DISTRO}" == "fedora" || "${DISTRO}" == "ubuntu" ]]; then
  install "fd-find"
  [[ "${DISTRO}" == "ubuntu" ]] && link_bin $(which fdfind) "fd"
else
  install "fd"
fi

install_bash_git_prompt

if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
  echo "= clang"
  install "clang"
fi

if [[ "${DISTRO}" != "fedora" ]]; then
  echo "= ruby"
  install "rbenv"
  install "ruby-build"
fi

echo "= python"
install_pyenv

if [[ "$(pyenv global)" != "3.9.2" ]]; then
  pyenv install 3.9.2 --skip-existing
  pyenv global 3.9.2
fi

echo "= node"
install_nvm

echo "= rust"
install_rustup

echo "= emacs-config"
EMACS_DIR="${DIR}/../emacs-config"

if [[ ! -d "${EMACS_DIR}" ]]; then
  echo "- cloning"
  git clone -q git@github.com:angelini/emacs-config.git "${EMACS_DIR}" > /dev/null
  ln -s "${EMACS_DIR}" "${HOME}/.emacs.d"
fi
link "../emacs-config" "emacs.d"

echo "= cask"
install_cask
cd "${EMACS_DIR}"
cask
cd "${DIR}"
