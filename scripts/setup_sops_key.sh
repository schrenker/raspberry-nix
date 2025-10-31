#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./setup_sops_key.sh

Setup sops encryption key on the cluster.
1. If key exists on a cluster, reuse it
2. If key does not exist on a cluster, reuse local one
3. If key exists neither on cluster, nor locally, generate a new one
'
    exit
fi

cd "$(git rev-parse --show-toplevel)"

main() {
    if KEYS=$(kubectl get secret sops-key --namespace sops --output jsonpath='{.data.keys\.txt}' | base64 -d); then
        echo "$KEYS" >./keys.txt
    else
        age-keygen --output ./keys.txt 2>/dev/null || echo "Key exists, not overwriting"
        kubectl create namespace sops --dry-run=client --output=yaml | kubectl apply --filename -
        kubectl create secret generic sops-key --namespace sops --from-file=./keys.txt
    fi

    AGEKEY=$(grep 'public' ./keys.txt | awk '{print $4}')
    cat <<EOF >./.sops.yaml
---
creation_rules:
    - age: >-
        $AGEKEY
      encrypted_suffix: Templates
EOF

}

main "$@"
