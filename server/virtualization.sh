#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

install_virtualization() {
    log "install virtualization"
    sudo dnf group install -y virtualization > /dev/null
}

set_cgroups_v1() {
    if ! grep -q systemd.unified_cgroup_hierarchy=0 /proc/cmdline; then
        log "set cgroups v1"
        install grubby
        sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
    fi
}

disable_selinux() {
    log "disable SELINUX"
    sudo setenforce 0
    sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
}

enable_nested_virtualization() {
    log "enable nested virtualization"
    sudo sed -i 's/#options kvm_amd nested=1/options kvm_amd nested=1/' /etc/modprobe.d/kvm.conf
}

add_docker_repo() {
    add_dnf_repo "docker-ce" "https://download.docker.com/linux/fedora/docker-ce.repo"
}

install_docker() {
    install docker-ce
    install docker-ce-cli
    install docker-compose

    sudo usermod -a -G docker "${USER}"
    sudo systemctl enable docker > /dev/null
}

install_containerd() {
    local config="/etc/containerd/config.toml"

    install containerd.io
    sudo systemctl enable containerd > /dev/null

    containerd config default | sudo tee "${config}" > /dev/null
    sudo sed -i '/\[plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options\]/a \            SystemdCgroup = true' "${config}"
}

main() {
    if ! grep -q -E "svm|vmx" /proc/cpuinfo; then
        error "Hardware virtualization not supported"
    fi

    add_docker_repo
    update_dnf

    install_virtualization
    install_docker
    install_containerd

    set_cgroups_v1
    disable_selinux
    enable_nested_virtualization

    log "REMINDER: restart this node"
}

main "$@"
