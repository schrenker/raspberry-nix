#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./cilium_policy.sh
Check policy audit mode on the cluster
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    CILIUM_NAMESPACE="cilium"
    CILIUM_AGENT_LABEL="k8s-app=cilium"

    CILIUM_PODS=$(kubectl get pods -n $CILIUM_NAMESPACE -l $CILIUM_AGENT_LABEL -o jsonpath='{.items[*].metadata.name}')

    echo "Checking Cilium Host Policy Audit Mode on all nodes..."
    echo "--------------------------------------------------------"

    for POD in $CILIUM_PODS; do
        NODE_NAME=$(kubectl get pod -n $CILIUM_NAMESPACE $POD -o jsonpath='{.spec.nodeName}')

        HOST_EP_ID=$(kubectl -n $CILIUM_NAMESPACE exec $POD -c cilium-agent -- cilium-dbg endpoint list -o jsonpath='{[?(@.status.identity.id==1)].id}')

        if [ -n "$HOST_EP_ID" ]; then
            AUDIT_STATUS=$(kubectl exec -n $CILIUM_NAMESPACE $POD -c cilium-agent -- \
                cilium-dbg endpoint config $HOST_EP_ID 2>/dev/null | grep PolicyAuditMode | awk '{print $3}')

            echo "Node: $NODE_NAME (Pod: $POD, Host EP ID: $HOST_EP_ID)"
            echo "  PolicyAuditMode: $AUDIT_STATUS"
        fi
        echo "---"
    done
}

main "$@"
