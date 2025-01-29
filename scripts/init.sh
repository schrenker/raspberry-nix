#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./init.sh
Bootstrap cluster:
1 .Install cilium to the cluster
2. Install argocd
3. Install argocd-apps, which contains app of apps Application
4. Argocd takes over control over itself and cilium, installing other applications as well
5. Print password, forward port and then open Safari tab pointing to argocd web ui
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    helm repo add cilium https://helm.cilium.io
    helm dependency build workloads/cilium
    helm upgrade --install --create-namespace --namespace cilium cilium workloads/cilium

    helm repo add argocd https://argoproj.github.io/argo-helm/
    helm dependency build workloads/argocd
    helm upgrade --install --create-namespace --namespace argocd argocd workloads/argocd

    helm dependency build workloads/argocd-apps
    helm upgrade --install --namespace argocd argocd-apps workloads/argocd-apps

    ./scripts/open-argo.sh
}

main "$@"
