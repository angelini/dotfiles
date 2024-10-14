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

readonly NVM_INSTALL_VERSION="0.40.1"  # NVM_VERSION conflicts with nvm.sh
readonly GO_VERSION="1.23.2"
readonly DUST_VERSION="1.1.1"
readonly HELM_VERSION="3.16.1"

log() {
    echo "$(date +"%H:%M:%S") - $(printf '%s' "$@")" 1>&2
}

error() {
    local message="${1}"

    echo "$(date +"%H:%M:%S") - ERROR: $(printf '%s' "${message}")" >&2
    exit 55
}

not_implemented() {
    local component="${1}"

    error "not implemented: ${component}"
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
    elif [[ "${OSTYPE}" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

detect_arch() {
    local arch="$(arch)"

    if [[ "${arch}" == arm* || "${arch}" == aarch* ]]; then
        echo "arm"
    else
        echo "x86"
    fi
}

detect_os_and_arch() {
    echo "$(detect_os)-$(detect_arch)"
}

detect_distro() {
    if bin_exists "apt-get"; then
        echo "debian"
    elif bin_exists "dnf"; then
        echo "fedora"
    elif bin_exists "brew"; then
        echo "macos"
    else
        error "unknown distro"
    fi
}

update_macos_package_manager() {
    brew upgrade > /dev/null
}

update_linux_package_manager() {
    case "$(detect_distro)" in
        "debian")
            sudo apt-get update -y > /dev/null
            ;;
        "fedora")
            sudo dnf update -y > /dev/null
            ;;
        *)
            not_implemented "update package manager for $(detect_distro)"
            ;;
    esac
}

update_package_manager() {
    log "updating package manager"

    case "$(detect_os)" in
        "linux")
            update_linux_package_manager
            ;;
        "macos")
            update_macos_package_manager
            ;;
        *)
            not_implemented "update package manager for $(detect_os)"
            ;;
    esac
}

check_linux() {
    local package="${1}"

    case "$(detect_distro)" in
        "debian")
            dpkg -s "${package}" &> /dev/null
            ;;
        "fedora")
            dnf list installed "${package}" &> /dev/null
            ;;
        *)
            not_implemented "check linux package manager for $(detect_distro)"
            ;;
    esac
}

check_macos() {
    local package="${1}"

    brew list "${package}" &> /dev/null
}

check() {
    local package="${1}"

    case "$(detect_os)" in
        "linux")
            check_linux "${package}"
            ;;
        "macos")
            check_macos "${package}"
            ;;
        *)
            not_implemented "check package manager for $(detect_os)"
            ;;
    esac
}

install_linux() {
    local package="${1}"

    case "$(detect_distro)" in
        "debian")
            sudo apt-get install -y "${package}" > /dev/null
            ;;
        "fedora")
            sudo dnf install -y "${package}" > /dev/null
            ;;
        *)
            not_implemented "linux install for $(detect_distro)"
            ;;
    esac
}

install_macos() {
    brew install -f "${package}" > /dev/null
}

install() {
    local package="${1}"

    if ! check "${package}"; then
        log "installing ${package}"

        case "$(detect_os)" in
            "linux")
                install_linux "${package}"
                ;;
            "macos")
                install_macos "${package}"
                ;;
            *)
                not_implemented "install for $(detect_os)"
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

os_awk() {
    case "$(detect_os)" in
        "linux")
            awk "$@"
            ;;
        "macos")
            gawk "$@"
            ;;
        *)
            not_implemented "gawk for $(detect_os)"
            ;;
    esac
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
    os_awk -i inplace '!seen[$0]++' "${ssh_dir}/authorized_keys"
}

setup_repos_dir() {
    log "setting up repos directory"
    mkdir -p "${REPOS_DIR}"

    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        log "cloning dotfiles"
        git clone -q git@github.com:angelini/dotfiles.git "${DOTFILES_DIR}"
    fi
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
    if [[ "$(detect_os)" == "linux" ]]; then
        install "ca-certificates"
        install "gnupg2"
        install "fd-find"

        install_github_tar "dust" \
            "dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu/dust" \
            "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    fi

    if [[ "$(detect_os)" == "macos" ]]; then
        install "gnupg"
        install "fd"
    fi

    install "bash-completion"
    install "findutils"
    install "htop"
    install "jq"
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

install_go() {
    if ! bin_exists "go"; then
        if [[ "$(detect_os)" == "macos" ]]; then
            not_implemented "macos install go"
        fi

        log "installing go"

        case "$(detect_arch)" in
            "x86")
                curl -fsSL -o "/tmp/golang.tar.gz" "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
                ;;
            "arm")
                curl -fsSL -o "/tmp/golang.tar.gz" "https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz"
                ;;
            *)
                not_implemented "linux install go for $(detect_arch)"
                ;;
        esac
        sudo tar -C "/usr/local" -xzf "/tmp/golang.tar.gz"
    fi
}

install_dev_toolchains() {
    install "python"

    if [[ "$(detect_distro)" == "fedora" ]]; then
        install "clang"
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
        install "clang"
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

    case "$(detect_os_and_arch)" in
        "linux-x86")
            install_github_tar "helm" \
                "linux-amd64/helm" \
                "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
            ;;
        "linux-arm")
            install_github_tar "helm" \
                "linux-arm64/helm" \
                "https://get.helm.sh/helm-v${HELM_VERSION}-linux-arm64.tar.gz"
            ;;
        "macos-arm")
            install_github_tar "helm" \
                "darwin-arm64/helm" \
                "https://get.helm.sh/helm-v${HELM_VERSION}-darwin-arm64.tar.gz"
            ;;
        *)
            not_implemented "install helm for $(detect_os_and_arch)"
            ;;
    esac

    install_rustup
    install_nvm
    install_go
}

install_kitty() {
    if ! bin_exists "kitty"; then
        log "installing kitty"
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

        mkdir -p "${CONFIG_DIR}/kitty"
        link "kitty.conf" "${CONFIG_DIR}/kitty/kitty.conf"
    fi

    if [[ ! -d "${CONFIG_DIR}/kitty/kitty-themes" ]]; then
        log "installing kitty-themese"
        git clone --depth 1 https://github.com/dexpota/kitty-themes.git "${CONFIG_DIR}/kitty/kitty-themes"
        (
            cd "${CONFIG_DIR}/kitty"
            ln -s "./kitty-themes/themes/Solarized_Light.conf"
        )
    fi
}

install_starship() {
    if ! bin_exists "starship"; then
        log "installing starship"
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    fi
}

source_bashrc() {
    log "sourcing .bashrc"

    set +u
    source "${HOME}/.bashrc"
    set -u
}

install_gcp_cli_repo() {
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
        "macos")
            curl -fsSL -o "/tmp/gcloud.tar.gz" "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz"
            ;;
        *)
            not_implemented
            ;;
    esac
}

install_gcp_cli() {
    if ! bin_exists "gcloud"; then
        log "installing gcp cli"

        if [[ "$(detect_os)" == "linux" ]]; then
            install_gcp_cli_repo
        fi

        install "google-cloud-sdk"
        gcloud init --skip-diagnostics
    fi
}

setup_cloud_dir() {
    mkdir -p "${CLOUD_DIR}"
    install_gcp_cli
}

main() {
    sudo echo "" > /dev/null
    log "sudo access cached"

    local os=$(detect_os)
    log "detected os:     ${os}"

    local distro="$(detect_distro)"
    local arch="$(detect_arch)"
    log "detected distro: ${distro}"
    log "detected arch:   ${arch}"

    update_package_manager

    if [[ "$(detect_os)" == "macos" ]]; then
        install "gawk"
    fi

    setup_bin_dir
    setup_ssh_dir

    test_github_keys
    setup_repos_dir

    install_alias_complete

    link_configs
    source_bashrc

    install_utilities
    install_dev_toolchains

    setup_cloud_dir

    install_kitty
    install_starship

    source_bashrc
    log "setup successful"
}

main "$@"
