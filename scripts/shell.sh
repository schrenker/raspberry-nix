#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]] || [[ $# -eq 0 ]]; then
    echo 'Usage: ./shell.sh NAME

Connect to machine via ssh using its NAME only. Ignore host key checking and known hosts file. Pass rest of the parameters as a command.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    IP=$(nix eval .#nixosConfigurations."$1".config.networking.interfaces.end0.ipv4.addresses --json | jq -r .[0].address)
    shift
    ssh nixos@"$IP" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" "$@"
}

main "$@"
