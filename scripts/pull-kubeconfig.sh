#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./pull-kubeconfig.sh IP
    Pull kubeconfig file from k3s server at IP address.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    ssh nixos@"$1" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null sudo cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$1/g" >.kube/config
}

main "$@"
