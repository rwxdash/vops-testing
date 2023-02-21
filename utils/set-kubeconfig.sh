#!/bin/bash -ex

CLUSTER_API_ENDPOINT=$(aws ssm get-parameters \
    --with-decryption \
    --name kubernetes-cluster-api-address \
    --region us-west-2 \
    | jq -r '.Parameters[0].Value')

mkdir -p ~/.kube

pushd ~/.kube

[ -f config ] && mv config config-$(date +%s%3N).bak
touch config
CLUSTER_KUBECONFIG=$(aws ssm get-parameters \
    --with-decryption \
    --name kubernetes-cluster-kubeconfig \
    --region us-west-2 \
    | jq -r '.Parameters[0].Value')

echo -e "$CLUSTER_KUBECONFIG" >> config
sed -ie "s~[[:space:]]*server:.*~    server: $CLUSTER_API_ENDPOINT~g" config

popd
