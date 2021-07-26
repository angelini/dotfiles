#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

# TODO: `sudo usermod -a -G docker "${USER}"`

install_virtualization() {
    log "install virtualization"
    sudo dnf group install -y virtualization > /dev/null
}

install_containerd() {
    install containerd
    sudo systemctl enable containerd > /dev/null
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

main() {
    if ! grep -q -E "svm|vmx" /proc/cpuinfo; then
        error "Hardware virtualization not supported"
    fi

    update_dnf

    install_virtualization
    install_containerd

    set_cgroups_v1
    disable_selinux
    enable_nested_virtualization

    log "REMINDER: restart this node"
}

main "$@"
