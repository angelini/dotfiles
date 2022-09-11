#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

readonly GITHUB_USER="angelini"
readonly LOCALE="en_US.UTF-8"

readonly CONFIG_DIR="${HOME}/.config"
readonly BIN_DIR="${HOME}/bin"
readonly CLOUD_DIR="${HOME}/cloud"
readonly REPOS_DIR="${HOME}/repos"
readonly DOTFILES_DIR="${REPOS_DIR}/dotfiles"

readonly PYTHON_VERSION="3.9.2"
readonly NVM_INSTALL_VERSION="0.38.0"  # NVM_VERSION conflicts with nvm.sh
readonly GO_VERSION="1.16.6"
readonly DUST_VERSION="0.6.1"
readonly HELM_VERSION="3.6.3"
readonly EJSON_VERSION="1.3.0"
readonly MKCERT_VERSION="1.4.3"

log() {
    echo "$(date +"%H:%M:%S") - $(printf '%s' "$@")" 1>&2
}

error() {
    local message="${1}"

    echo "$(date +"%H:%M:%S") - ERROR: $(printf '%s' "${message}")" >&2
    exit 55
}

not_implemented() {
    error "not implemented"
}

ask() {
    local question="${1}"

    read -rp "=> ${question} [y/N] " response
    case "${response}" in
        [Yy]*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

bin_exists() {
    type -t "${1}" &> /dev/null
}

detect_os() {
    if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "${OSTYPE}" == "darwin" ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

detect_arch() {
    local arch="$(arch)"

    if [[ "${arch}" == amd* || "${arch}" == aarch* ]]; then
        echo "arm"
    else
        echo "x86"
    fi
}

detect_distro() {
    if bin_exists "apt-get"; then
        echo "debian"
    elif bin_exists "dnf"; then
        echo "fedora"
    else
        error "unknown distro"
    fi
}

is_wsl() {
    if [[ "$(detect_os)" == "linux" ]]; then
        grep -q "microsoft" "/proc/sys/kernel/osrelease"
    else
        return 1
    fi
}

update_package_manager() {
    log "updating package manager"

    case "$(detect_distro)" in
        "debian")
            sudo apt-get update -y > /dev/null
            ;;
        "fedora")
            sudo dnf update -y > /dev/null
            ;;
        *)
            not_implemented
            ;;
    esac
}

check() {
    local package="${1}"

    case "$(detect_distro)" in
        "debian")
            dpkg -s "${package}" &> /dev/null
            ;;
        "fedora")
            dnf list installed "${package}" &> /dev/null
            ;;
        *)
            not_implemented
            ;;
    esac
}

install() {
    local package="${1}"

    if ! check "${package}"; then
        log "installing ${package}"

        case "$(detect_distro)" in
            "debian")
                sudo apt-get install -y "${package}" > /dev/null
                ;;
            "fedora")
                sudo dnf install -y "${package}" > /dev/null
                ;;
            *)
                not_implemented
                ;;
        esac
    fi
}

link() {
    local target="${DOTFILES_DIR}/${1}"
    local link="${HOME}/.${1}"
    if [[ -n "${2:-}" ]]; then
        link="${2}"
    fi

    if [[ ! -e "${link}" ]]; then
        log "linking ${target} to ${link}"
        ln -s "${target}" "${link}"
    fi
}

update_locale() {
    if [[ "${LANG}" != "${LOCALE}" ]]; then
        log "update locale to ${LOCALE}"

        if [[ "$(detect_distro)" == "debian" ]]; then
            sudo locale-gen "${LOCALE}"
        fi

        if is_wsl; then
            sudo update-locale "LANG=${LOCALE}"
        else
            sudo localectl set-locale "LANG=${LOCALE}"
        fi
        error "locale changed, open a new shell and run again"
    fi
}

update_hostname() {
    log "current hostname is $(hostname)"

    if ask "do you want to update the hostname?"; then
        read -rp "new hostname: " new_hostname

        log "updating hostname to ${new_hostname}"
        sudo hostnamectl set-hostname "${new_hostname}"
    fi
}

add_user_groups() {
    log "adding $(whoami) to systemd-journal"
    sudo usermod -a -G systemd-journal "$(whoami)"
}

setup_bin_dir() {
    log "setting up bin directory"
    mkdir -p "${BIN_DIR}"
}

setup_ssh_dir() {
    log "setting up ssh directory"

    local ssh_dir="${HOME}/.ssh"

    mkdir -p "${ssh_dir}"
    chmod 700 "${ssh_dir}"

    if [[ ! -f "${ssh_dir}/id_ed25519" ]]; then
        log "generating SSH keys"
        ssh-keygen -t ed25519 -a 100 -q -N "" -f "${ssh_dir}/id_ed25519" -C "$(whoami)@$(hostname)"
    fi

    curl -fsSL "https://github.com/${GITHUB_USER}.keys" >> "${ssh_dir}/authorized_keys"
    awk -i inplace '!seen[$0]++' "${ssh_dir}/authorized_keys"
}

setup_repos_dir() {
    log "setting up repos directory"
    mkdir -p "${REPOS_DIR}"

    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        log "cloning dotfiles"
        git clone -q git@github.com:angelini/dotfiles.git "${DOTFILES_DIR}"
    fi
}

setup_vms_dir() {
    log "setting up vms directory"
    mkdir -p "${HOME}/vms"
}

test_github_keys() {
    log "testing SSH keys with Github"

    set +e
    ssh -T git@github.com &> /dev/null

    if [[ "${?}" == 255 ]]; then
        error "SSH key not stored on Github, add it to: https://github.com/settings/keys"
    fi
    set -e
}

link_configs() {
    log "linking user config files"
    mkdir -p "${CONFIG_DIR}"

    link "aliases"
    link "gitconfig"
    link "gitignore_global"

    link "flake8" "${CONFIG_DIR}/flake8"
    link "starship.toml" "${CONFIG_DIR}/starship.toml"

    log "resetting bashrc"
    rm -f "${HOME}/.bashrc"
    link "bashrc"
}

install_alias_complete() {
    local dir="${HOME}/.bash_completion.d"

    if [[ ! -f "${dir}/complete_alias" ]]; then
        log "installing alias complete"
        mkdir -p "${dir}"
        curl -fsSL "https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias" > "${dir}/complete_alias"
    fi
}

install_github_bin() {
    local name="${1}"
    local uri="${2}"

    local path="${HOME}/bin/${name}"

    if ! bin_exists "${name}"; then
        log "installing ${name}"
        curl -fsSL -o "${path}" "${uri}"
        chmod +x "${path}"
    fi
}

install_github_tar() {
    local name="${1}"
    local target="${2}"
    local uri="${3}"

    local tmp="$(mktemp -d -t github-tar-XXXXX)"
    local tmp_tar="${tmp}/release.tar"
    local bin_path="${HOME}/bin/${name}"

    if ! bin_exists "${name}"; then
        log "installing ${name}"
        curl -fsSL -o "${tmp_tar}" "${uri}"
        tar -C "${tmp}" -xzf "${tmp_tar}"
        mv "${tmp}/${target}" "${bin_path}"
        chmod +x "${bin_path}"
    fi
}

install_utilities() {
    install "bash-completion"
    install "ca-certificates"
    install "fd-find"
    install "findutils"
    install "gnupg2"
    install "htop"
    install "jq"
    install "keychain"
    install "ripgrep"
    install "tree"
    install "vim"

    if [[ "$(detect_distro)" == "debian" ]]; then
        if [[ ! -f "${BIN_DIR}/fd" ]]; then
            ln -s "$(which fdfind)" "${BIN_DIR}/fd"
        fi

        install "apt-utils"
        install "apt-transport-https"
        install "fontconfig"
        install "unzip"
    fi

    install_github_tar "dust" \
        "dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu/dust" \
        "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
}

install_pyenv() {
    local pyenv_dir="${HOME}/.pyenv"

    if ! bin_exists "pyenv"; then
        log "installing pyenv"
        git clone -q https://github.com/yyuu/pyenv.git "${pyenv_dir}"

        (
            cd "${pyenv_dir}"
            src/configure
            make -C src
        )
    fi
}

install_rustup() {
    if ! bin_exists "rustup"; then
        log "installing rustup"
        curl -fsSL https://sh.rustup.rs | bash -s -- -y
    fi
}

install_nvm() {
    if ! bin_exists "nvm"; then
        log "installing nvm"
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_INSTALL_VERSION}/install.sh" | bash
    fi
}

install_java() {
    if ! bin_exists "java"; then
        case "$(detect_distro)" in
            "debian")
                install "openjdk-11-jdk"
                ;;
            "fedora")
                install "java-11-openjdk-devel"
                ;;
            *)
                not_implemented
                ;;
        esac
    fi
}

install_go() {
    if ! bin_exists "go"; then
        log "installing go"

        case "$(detect_arch)" in
            "x86")
                curl -fsSL -o "/tmp/golang.tar.gz" "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
                ;;
            "arm")
                curl -fsSL -o "/tmp/golang.tar.gz" "https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz"
                ;;
        esac
        sudo tar -C "/usr/local" -xzf "/tmp/golang.tar.gz"
    fi
}

install_dev_toolchains() {
    install "clang"
    install "protobuf-compiler"
    install "ruby"

    if [[ "$(detect_distro)" == "fedora" ]]; then
        install "bzip2-devel"
        install "libffi-devel"
        install "nss-tools"
        install "openssl-devel"
        install "readline-devel"
        install "sqlite-devel"
        install "xz-devel"
        install "zlib-devel"
    fi

    if [[ "$(detect_distro)" == "debian" ]]; then
        install "build-essential"
        install "libbz2-dev"
        install "libffi-dev"
        install "libnss3-tools"
        install "libssl-dev"
        install "libreadline-dev"
        install "libsqlite3-dev"
        install "pkg-config"
        install "xz-utils"
        install "zlib1g-dev"
    fi

    case "$(detect_arch)" in
        "x86")
            install_github_bin "ejson" \
                "https://github.com/Shopify/ejson/releases/download/v${EJSON_VERSION}/linux-amd64"
            install_github_bin "mkcert" \
                "https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/mkcert-v${MKCERT_VERSION}-linux-amd64"

            install_github_tar "helm" \
                "linux-amd64/helm" \
                "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
            ;;
        "arm")
            install_github_bin "ejson" \
                "https://github.com/Shopify/ejson/releases/download/v${EJSON_VERSION}/linux-arm64"
            install_github_bin "mkcert" \
                "https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/mkcert-v${MKCERT_VERSION}-linux-arm64"

            install_github_tar "helm" \
                "linux-arm64/helm" \
                "https://get.helm.sh/helm-v${HELM_VERSION}-linux-arm64.tar.gz"
            ;;
    esac

    install_pyenv
    install_rustup
    install_nvm
    install_java
    install_go

    if [[ "$(pyenv global)" != "${PYTHON_VERSION}" ]]; then
        pyenv install "${PYTHON_VERSION}" --skip-existing
        pyenv global "${PYTHON_VERSION}"
    fi

    pip install --upgrade pip > /dev/null
}

install_font() {
    local name="${1}"
    local uri="${2}"
    local font_zip="${uri##*/}"
    local fonts_dir="${HOME}/.fonts"

    if ! fc-list | grep "${name}" &> /dev/null; then
        log "installing font ${font_zip}"

        mkdir -p "${fonts_dir}"

        curl -fsSLO "${uri}"
        unzip -o "${font_zip}" -d "${fonts_dir}" > /dev/null
        fc-cache -fv > /dev/null
        rm "${font_zip}"
    fi
}

install_fonts() {
    install_font "Ubuntu Mono Nerd Font" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip"
}

install_starship() {
    if ! bin_exists "starship"; then
        log "installing starship"
        curl -fsSL https://starship.rs/install.sh | bash -s -- -y
    fi
}

source_bashrc() {
    log "sourcing .bashrc"

    set +u
    source "${HOME}/.bashrc"
    set -u
}

install_gcp_cli() {
    if ! bin_exists "gcloud"; then
        log "installing gcp cli"

        case "$(detect_distro)" in
            "debian")
                echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
                    | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

                curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
                    | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - > /dev/null

                update_package_manager
                ;;
            "fedora")
                sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo <<- EOM > /dev/null
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
    https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
                ;;
            *)
                not_implemented
                ;;
        esac

        install "google-cloud-sdk"
        gcloud init --skip-diagnostics
    fi
}

install_aws_cli() {
    if ! bin_exists "aws"; then
        log "installing aws cli"

        case "$(detect_arch)" in
            "x86")
                curl -fsSL -o "/tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
                ;;
            "arm")
                curl -fsSL -o "/tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
                ;;
        esac

        unzip -o "/tmp/awscliv2.zip" -d "${CLOUD_DIR}" > /dev/null
        sudo "${CLOUD_DIR}/aws/install"
    fi
}

setup_cloud_dir() {
    log "setting up cloud directory"
    mkdir -p "${CLOUD_DIR}"

    install_gcp_cli
    install_aws_cli
}

main() {
    sudo echo "" > /dev/null
    log "sudo access cached"

    local os=$(detect_os)
    log "detected os:     ${os}"

    if [[ "${os}" != "linux" ]]; then
        error "script only supports linux"
    fi

    local distro="$(detect_distro)"
    local arch="$(detect_arch)"
    log "detected distro: ${distro}"
    log "detected arch:   ${arch}"

    add_user_groups
    update_locale
    update_hostname
    update_package_manager

    setup_bin_dir
    setup_ssh_dir
    setup_vms_dir

    test_github_keys
    install "git"
    setup_repos_dir

    install_alias_complete

    link_configs
    source_bashrc

    install_utilities
    install_dev_toolchains

    setup_cloud_dir

    install_fonts
    install_starship

    source_bashrc
    log "setup successful"
}

main "$@"
