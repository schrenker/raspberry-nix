#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./init.sh
    Initialize talos cluster.
'
    exit
fi

cd "$(dirname "$0")"

main() {
    export CONTROL_PLANE_IP="192.168.1.170"
    export WORKER_IP=("192.168.1.171" "192.168.1.172" "192.168.1.173")
    export CLUSTER_NAME="raspberry"

    echo "CTL:: Generating talos secrets"
    talosctl gen secrets -o secrets.yaml

    echo "CTL:: Generating configuration"
    talosctl gen config --with-secrets secrets.yaml $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443

    echo "CTL:: patching configuration files"
    talosctl machineconfig patch controlplane.yaml --patch @raspberry.yaml --output controlplane.yaml
    talosctl machineconfig patch worker.yaml --patch @raspberry.yaml --output worker.yaml

    echo "CTL:: Applying configuration to Control Plane node"
    talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml

    echo "CTL:: Applying configuration to Worker Nodes"
    for ip in "${WORKER_IP[@]}"; do
        talosctl apply-config --insecure --nodes "$ip" --file worker.yaml
        echo "Configuration applied to $ip"
        echo ""
    done

    echo "CTL:: Configuring endpoint"
    talosctl config endpoint $CONTROL_PLANE_IP

    echo "CTL:: Bootstrapping cluster"
    talosctl bootstrap --nodes $CONTROL_PLANE_IP

    echo "CTL:: pulling kubeconfig"
    talosctl kubeconfig alternative-kubeconfig --nodes $CONTROL_PLANE_IP

    mv ./alternative-kubeconfig ../.kube/config

}

main "$@"
