#!/bin/bash 

echo " cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt

sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo apt purge -y dphys-swapfile
sudo apt autoremove -y

#cat <<EOF | sudo tee /etc/containerd/config.toml
#version = 2
#[plugins]
#  [plugins."io.containerd.grpc.v1.cri"]
#    [plugins."io.containerd.grpc.v1.cri".containerd]
#      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
#        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#          runtime_type = "io.containerd.runc.v2"
#          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#            SystemdCgroup = true
#EOF

#cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
#overlay
#br_netfilter
#EOF
 
# Forwarding IPv4 and letting iptables see bridged traffic
#sudo modprobe overlay
#sudo modprobe br_netfilter
 
#cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
#net.bridge.bridge-nf-call-iptables  = 1
#net.bridge.bridge-nf-call-ip6tables = 1
#net.ipv4.ip_forward                 = 1
#EOF
#sudo sysctl --system

sudo apt-get update

# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt remove -y kubectl kubelet kubeadm
sudo apt-get install -y kubelet kubeadm kubectl
