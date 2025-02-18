#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./open-argo.sh
Wait for argocd-server to come up, forward https to localhost:8080 and then open Safari browser tab pointing to it.
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    kubectl wait --timeout=600s --for=condition=Available=True -n argocd deployment argocd-server
    if [[ $(uname) == "Darwin" ]]; then
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | pbcopy && pbpaste && echo
        (sleep 1 && open -ga "Safari" "https://localhost:8080") &
    else
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
    fi
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

main "$@"
