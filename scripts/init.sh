#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./init.sh
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    helm repo add cilium https://helm.cilium.io
    helm dependency build workloads/cilium
    helm upgrade --install --create-namespace --namespace cilium cilium workloads/cilium

    helm repo add argocd https://argoproj.github.io/argo-helm/
    # helm repo update argocd
    # helm dependency update workloads/argocd
    helm dependency build workloads/argocd
    helm upgrade --install --create-namespace --namespace argocd argocd workloads/argocd

    # helm upgrade --install --create-namespace --namespace argocd --set="global.revision=HEAD" init workloads/init

    kubectl wait --timeout=600s --for=condition=Available=True -n argocd deployment argocd-server
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

main "$@"
