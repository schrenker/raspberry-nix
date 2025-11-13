#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./get_argo_pass.sh
Print argocd password to stdout.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    if [[ $(uname) == "Darwin" ]]; then
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | pbcopy && pbpaste && echo
    else
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
    fi
}

main "$@"
