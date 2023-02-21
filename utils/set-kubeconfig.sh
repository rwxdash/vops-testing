#!/bin/bash -ex

export AWS_PROFILE=personal

mkdir -p ~/.kube

pushd ~/.kube
rm config
touch config
CLUSTER_KUBECONFIG=$(aws ssm get-parameters \
    --with-decryption \
    --name kubernetes-cluster-kubeconfig \
    --region us-west-2 \
    | jq -r '.Parameters[0].Value')

echo -e "$CLUSTER_KUBECONFIG" >> config

popd
