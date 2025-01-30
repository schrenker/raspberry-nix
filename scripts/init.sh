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
    ./scripts/pull-kubeconfig.sh 192.168.1.65

    helm repo add cilium https://helm.cilium.io
    helm dependency update workloads/cilium/cilium
    helm upgrade --install --create-namespace --namespace cilium cilium workloads/cilium/cilium

    helm repo add argocd https://argoproj.github.io/argo-helm/
    helm dependency update workloads/argocd/argocd
    helm upgrade --install --create-namespace --namespace argocd argocd workloads/argocd/argocd

    helm dependency update workloads/argocd/argocd-apps
    helm upgrade --install --namespace argocd argocd-apps workloads/argocd/argocd-apps

    ./scripts/open-argo.sh
}

main "$@"
