#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

disable_swap() {
    log "disable swap"
    sudo systemctl stop "dev-zram0.swap"
    sudo systemctl mask "dev-zram0.swap"
}

enable_iptables_bridged_traffic() {
    log "enable bridged traffice in iptables"

    sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
}

enable_kernel_modules() {
    log "enable kernel modules"
    sudo tee /etc/modules-load.d/containerd.conf > /dev/null <<EOF
overlay
br_netfilter
EOF
}

add_k8s_repo() {
    log "add k8s repo"

    sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
}

install_k8s() {
    log "install k8s"
    sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes > /dev/null
}

link_cni_bins() {
    local opt_cni="/opt/cni"

    if [[ ! -d "${opt_cni}/bin" ]]; then
        log "link CNI binaries"
        sudo mkdir -p "${opt_cni}"
        sudo ln -s "/usr/libexec/cni" "${opt_cni}/bin"
    fi
}

main() {
    disable_swap
    enable_iptables_bridged_traffic
    enable_kernel_modules

    add_k8s_repo
    update_dnf
    install_k8s

    link_cni_bins

    log "REMINDER: restart this node"
}

main "$@"
