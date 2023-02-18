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
    curl \
    gnupg gnupg2 \
    lsb-release \
    containerd.io docker-ce docker-ce-cli \
    kubeadm kubelet kubectl kubernetes-cni

sudo apt-mark hold kubelet kubeadm kubectl
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

sudo hostnamectl set-hostname kubernetes-master

# ---

# Flannel uses the 10.244.0.0/16 CIDR in its pod network manifest.
EC2_PUBLIC_IP=$(curl checkip.amazonaws.com)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=$EC2_PUBLIC_IP

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown $(id -u ubuntu):$(id -u ubuntu) /home/ubuntu/.kube/config

sudo systemctl restart kubelet

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
EOF

chmod +x /tmp/init-script.sh
sudo -i -u ubuntu bash /tmp/init-script.sh
