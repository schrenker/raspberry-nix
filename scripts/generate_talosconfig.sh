#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./generate_talosconfig.sh
Generate talos configuration files based on talconfig.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    which talhelper >/dev/null

    talhelper genconfig -c talos/talconfig.yaml -s talos/talsecret.sops.yaml -o ./generated/ --no-gitignore
}

main "$@"
