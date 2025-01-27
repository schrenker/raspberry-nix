#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./get-cilium-policy-mode.sh
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    NODE_NAME=k3s-master
    CILIUM_NAMESPACE=cilium
    CILIUM_POD_NAME=$(kubectl -n $CILIUM_NAMESPACE get pods -l "k8s-app=cilium" -o jsonpath="{.items[?(@.spec.nodeName=='$NODE_NAME')].metadata.name}")
    HOST_EP_ID=$(kubectl -n $CILIUM_NAMESPACE exec $CILIUM_POD_NAME -- cilium-dbg endpoint list -o jsonpath='{[?(@.status.identity.id==1)].id}')
    kubectl -n $CILIUM_NAMESPACE exec $CILIUM_POD_NAME -- cilium-dbg status | grep 'Host firewall'
    kubectl -n $CILIUM_NAMESPACE exec $CILIUM_POD_NAME -- cilium-dbg endpoint config $HOST_EP_ID PolicyAuditMode=Enabled
    kubectl -n $CILIUM_NAMESPACE exec $CILIUM_POD_NAME -- cilium-dbg endpoint config $HOST_EP_ID | grep PolicyAuditMode
}

main "$@"
