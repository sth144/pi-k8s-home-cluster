#!/bin/bash
set -euo pipefail

# CHANGED: fixed package list continuation bug so both packages install reliably.
sudo apt install -y docker.io containerd.io

sudo systemctl enable docker
sudo systemctl start docker

sudo groupadd -f docker
sudo usermod -aG docker $USER
