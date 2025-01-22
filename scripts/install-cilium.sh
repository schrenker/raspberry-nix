#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./install-cilium.sh
    Install cilium to k3s, based on current kubeconfig.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    API_SERVER_IP="$(kubectl cluster-info | grep -oEm 1 '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
    cilium install --set kubeProxyReplacement=true --set k8sServiceHost="${API_SERVER_IP}" --set k8sServicePort=6443
}

main "$@"
