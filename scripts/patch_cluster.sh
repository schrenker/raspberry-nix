#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./patch_cluster.sh
    Patch cluster based on patch configuration/base.yaml file
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {

    which talhelper >/dev/null

    talhelper genconfig -c talos/talconfig.yaml -s talos/talsecret.sops.yaml -o configuration/ --no-gitignore

    while read -r HOSTNAME IP_ADDRESS; do
        talosctl apply-config --nodes "$IP_ADDRESS" --file ./configuration/raspberry-"$HOSTNAME".yaml
    done < <(yq -r '.nodes[] | .hostname + " " + .ipAddress' ./talos/talconfig.yaml)
}

main "$@"
