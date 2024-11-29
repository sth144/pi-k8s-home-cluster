
#!/bin/bash

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

# Generate token for worker nodes to join the cluster
echo "kubeadm reset" > join-command.sh
kubeadm token create --print-join-command >> join-command.sh
chmod +x join-command.sh

# Run the join command on worker nodes
ssh picocluster@$WORKER1_IP 'bash -s' < join-command.sh
ssh picocluster@$WORKER2_IP 'bash -s' < join-command.sh

kubectl taint node pc0 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node pc0 node-role.kubernetes.io/master:NoSchedule-
