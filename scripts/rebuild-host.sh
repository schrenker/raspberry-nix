#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./rebuild-host.sh NAME
    Rebuild host NAME remotely with corresponding flake configuration.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    export NIX_SSHOPTS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    IP=$(nix eval .#nixosConfigurations."$1".config.networking.interfaces.end0.ipv4.addresses --json | jq -r .[0].address)
    nixos-rebuild switch --flake .#"$1" --target-host nixos@"$IP" --build-host nixos@"$IP" --fast --use-remote-sudo
}

main "$@"
