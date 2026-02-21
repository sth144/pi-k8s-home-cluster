#!/bin/bash

sudo apt install -y \
  docker.io \
  # docker-ce \
  # docker-ce-cli \
  containerd.io

sudo systemctl enable docker
sudo systemctl start docker

sudo groupadd docker
sudo usermod -aG docker $USER
