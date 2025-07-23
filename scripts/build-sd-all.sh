#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./build-all-sd-aarch64.sh
    Build all sd-aarch64 images based flake.nix.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    nix flake show --json | jq -r '.nixosConfigurations | keys.[]' | while read -r line; do
        ./scripts/build-sd.sh "$line"
    done

}

main "$@"
