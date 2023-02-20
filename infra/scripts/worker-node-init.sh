#!/bin/bash -ex

cat <<'EOF' >> /tmp/init-script.sh
#!/bin/bash -ex

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    curl jq unzip \
    gnupg gnupg2 \
    lsb-release \
    containerd.io docker-ce docker-ce-cli \
    kubeadm kubelet kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

pushd /tmp

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

popd

sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo tee /etc/docker/daemon.json <<EOT
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOT

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd

# ---

# Tempopary solution until I figure out a way to make sure
# master node is set up successfully.
sleep 60

# ---

KUBEADM_TMP_JOIN_COMMAND=$(aws ssm get-parameters \
    --with-decryption \
    --name kubernetes-cluster-tmp-join-command \
    --region us-west-2 \
    | jq -r '.Parameters[0].Value')

sudo -s eval $KUBEADM_TMP_JOIN_COMMAND

mkdir -p /home/ubuntu/.kube

pushd /home/ubuntu/.kube
touch config
CLUSTER_KUBECONFIG=$(aws ssm get-parameters \
    --with-decryption \
    --name kubernetes-cluster-kubeconfig \
    --region us-west-2 \
    | jq -r '.Parameters[0].Value')

echo -e "$CLUSTER_KUBECONFIG" >> config
popd

sudo chown $(id -u ubuntu):$(id -u ubuntu) /home/ubuntu/.kube/config

sudo systemctl restart kubelet
EOF

chmod +x /tmp/init-script.sh
sudo -i -u ubuntu bash /tmp/init-script.sh
