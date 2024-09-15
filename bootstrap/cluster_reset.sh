#!/bin/bash

# Reset Kubernetes on the master node
echo "Resetting Kubernetes on the master node..."
kubeadm reset -f

# Clean up Kubernetes artifacts
echo "Cleaning up Kubernetes artifacts..."
sudo rm -rf /etc/kubernetes/
sudo rm -rf $HOME/.kube

# Remove Docker containers and images
echo "Removing Docker containers and images..."
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -q) -f
# Remove Flannel network interface
echo "Removing Flannel network interface..."
sudo ip link delete cni0
sudo ip link delete flannel.1

# Reset iptables rules
echo "Resetting iptables rules..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Remove Kubernetes binaries and configurations
#echo "Removing Kubernetes binaries and configurations..."
#sudo apt purge -y kubeadm kubectl kubelet kubernetes-cni

# Reboot the node to ensure a clean state
echo "Rebooting the node to apply changes..."
sudo reboot
