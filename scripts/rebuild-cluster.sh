#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./rebuild-cluster.sh
    Rebuild all nodes within cluster.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nix flake show --json | jq -r '.nixosConfigurations | keys.[]' | while read -r line; do
        # Stdin redirection to prevent stdin hijacking
        ./scripts/rebuild-host.sh "$line" </dev/null
    done

}

main "$@"
