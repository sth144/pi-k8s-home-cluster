#!/bin/bash
set -euo pipefail

# Variables
MASTER_IP=192.168.1.240
WORKER1_IP=pc1
WORKER2_IP=pc2

# Initialize Kubernetes on the master node
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Mem

# Copy kubeadm config to user's home directory
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CHANGED: keep join command in-memory so token is not written to disk.
JOIN_COMMAND="$(kubeadm token create --print-join-command)"

# Run the join command on worker nodes
ssh picocluster@$WORKER1_IP "sudo kubeadm reset -f && sudo ${JOIN_COMMAND}"
ssh picocluster@$WORKER2_IP "sudo kubeadm reset -f && sudo ${JOIN_COMMAND}"

# CHANGED: taint removal is best-effort for repeatable runs.
kubectl taint node pc0 node-role.kubernetes.io/control-plane:NoSchedule- || true
kubectl taint node pc0 node-role.kubernetes.io/master:NoSchedule- || true

kubectl apply -f $HOME/Projects/network/coredns-patch.yaml
kubectl rollout restart deployment coredns -n kube-system
