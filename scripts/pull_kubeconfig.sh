#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pull_kubeconfig.sh
    Pull kubeconfig file from talos-master.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    which talosctl >/dev/null

    mkdir -p .kube
    echo "MSG:: pulling kubeconfig"
    talosctl kubeconfig ./kube/config --nodes "$CPLANE_IP"
}

main "$@"
