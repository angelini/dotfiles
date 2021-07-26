#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

readonly FLANNEL_YAML="https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
readonly NETWORK_CIDR="10.244.0.0/16"

create_cluster() {
    log "create cluster on ${NETWORK_CIDR}"
    sudo kubeadm init --pod-network-cidr="${NETWORK_CIDR}" \
        --cri-socket=/run/containerd/containerd.sock
}

setup_kube_config() {
    log "setup kube config"

    local config_dir="${HOME}/.kube"
    local config_file="${config_dir}/config"

    mkdir -p "${config_dir}"

    if [[ ! -f "${config_file}" ]]; then
        sudo cp -i /etc/kubernetes/admin.conf "${config_file}"
        sudo chown "$(id -u):$(id -g)" "${config_file}"
    fi
}

add_flannel() {
    log "add flannel"
    kubectl apply -f "${FLANNEL_YAML}" > /dev/null
}

untaint_master_node() {
    log "untaint master node"
    kubectl taint nodes --all node-role.kubernetes.io/master- > /dev/null
}

main() {
    create_cluster
    setup_kube_config

    add_flannel
    untaint_master_node
}

main "$@"
