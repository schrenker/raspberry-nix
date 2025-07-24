#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then

    echo 'Usage: ./encrypt.sh FILE

Encrypt a file with sops for cluster use.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    ./scripts/setup-sops-key.sh

    sops --encrypt --in-place "$1"

}

main "$@"
