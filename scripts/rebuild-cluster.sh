#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./rebuild-cluster.sh
    Rebuild all nodes within cluster. For now this is opinionated regarding IP addressing.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    ./scripts/rebuild-host.sh k3s-master 192.168.1.65
    ./scripts/rebuild-host.sh k3s-node01 192.168.1.66
}

main "$@"
