#!/bin/bash

sudo apt-get update

sudo apt-get install -y vim \
  jq \
  nodejs \
  npm \
  neofetch \
  samba

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

sudo systemctl enable nodeexporter.service
sudo systemctl start nodeexpoerter.service


