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
    which talhelper >/dev/null

    mkdir -p ./talos

    if [[ ! -f ./talos/talsecret.sops.yaml ]]; then
        echo "MSG:: Talsecret doesn't exist, generating and encrypting."
        talhelper gensecret >./talos/talsecret.sops.yaml
        ./scripts/encrypt.sh ./talos/talsecret.sops.yaml
    fi

    echo "MSG:: Generating machine configurations."
    talhelper genconfig -c ./talos/talconfig.yaml -s ./talos/talsecret.sops.yaml -o generated/ --no-gitignore

    echo "MSG:: Applying machine configurations."
    while read -r HOSTNAME IP_ADDRESS; do
        talosctl apply-config --nodes "$IP_ADDRESS" --file ./generated/raspberry-"$HOSTNAME".yaml --insecure
    done < <(yq -r '.nodes[] | .hostname + " " + .ipAddress' ./talos/talconfig.yaml)

    CPLANE_IP=$(yq -r '.nodes[] | select(.hostname == "talos-master") | .ipAddress' ./talos/talconfig.yaml)

    echo "MSG:: Configuring endpoint"
    talosctl config endpoint "$CPLANE_IP"

    echo "MSG:: Sleep for 3 minutes for NTP to catch up..."
    sleep 180

    echo "MSG:: Bootstrapping cluster."
    talosctl bootstrap --nodes "$CPLANE_IP"

    echo "MSG:: Pulling kubeconfig."
    ./scripts/pull_kubeconfig.sh

    echo "MSG:: Installing base components."
    ./scripts/base_init.sh

}

main "$@"
