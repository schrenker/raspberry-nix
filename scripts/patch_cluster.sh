#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./patch_cluster.sh
    Patch cluster based on patch configuration/raspberry.yaml file
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    echo "MSG:: patching configuration files"
    talosctl machineconfig patch ./talos/controlplane.yaml --patch @./configuration/raspberry.yaml --output ./talos/controlplane.yaml
    talosctl machineconfig patch ./talos/worker.yaml --patch @./configuration/raspberry.yaml --output ./talos/worker.yaml

    echo "MSG:: Applying configuration to Control Plane node"
    talosctl apply-config --nodes "$CPLANE_IP" --file ./talos/controlplane.yaml

    echo "MSG:: Applying configuration to Worker Nodes"
    for ip in $WORKER_IP; do
        talosctl apply-config --nodes "$ip" --file ./talos/worker.yaml
        echo "Configuration applied to $ip"
        echo ""
    done
}

main "$@"
