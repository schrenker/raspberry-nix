#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./talos_init.sh
    Initialize talos cluster.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    which talosctl >/dev/null

    mkdir -p ./talos

    echo "MSG:: Generating talos secrets"
    talosctl gen secrets -o ./talos/secrets.yaml

    echo "MSG:: Generating configuration"
    talosctl gen config -o ./talos --with-secrets ./talos/secrets.yaml "$CLUSTER_NAME" https://"$CPLANE_IP":6443

    echo "MSG:: patching configuration files"
    talosctl machineconfig patch ./talos/controlplane.yaml --patch @./configuration/raspberry.yaml --output ./talos/controlplane.yaml
    talosctl machineconfig patch ./talos/worker.yaml --patch @./configuration/raspberry.yaml --output ./talos/worker.yaml

    echo "MSG:: Applying configuration to Control Plane node"
    talosctl apply-config --insecure --nodes "$CPLANE_IP" --file ./talos/controlplane.yaml

    echo "MSG:: Applying configuration to Worker Nodes"
    for ip in "${WORKER_IP[@]}"; do
        talosctl apply-config --insecure --nodes "$ip" --file ./talos/worker.yaml
        echo "Configuration applied to $ip"
        echo ""
    done

    echo "MSG:: Configuring endpoint"
    talosctl config endpoint "$CPLANE_IP"

    echo "MSG:: Sleep for 3 minutes for NTP to catch up..."

    echo "MSG:: Bootstrapping cluster"
    talosctl bootstrap --nodes "$CPLANE_IP"

    ./scripts/pull_kubeconfig.sh

    ./scripts/base_init.sh

}

main "$@"
