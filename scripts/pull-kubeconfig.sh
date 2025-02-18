#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pull-kubeconfig.sh
    Pull kubeconfig file from k3s master.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    mkdir -p .kube
    IP=$(nix eval .#nixosConfigurations.k3s-master.config.networking.interfaces.end0.ipv4.addresses --json | jq -r .[0].address)
    ssh nixos@"$IP" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null sudo cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$IP/g" >.kube/config
}

main "$@"
