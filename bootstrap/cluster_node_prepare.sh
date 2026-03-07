#!/bin/bash
set -euo pipefail

sudo apt-get update

sudo apt-get install -y vim \
  jq \
  nodejs \
  npm \
  neofetch \
  samba

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# CHANGED: fixed service name typo and avoid hard failure if service is not installed.
if systemctl list-unit-files | grep -q '^nodeexporter\.service'; then
  sudo systemctl enable nodeexporter.service
  sudo systemctl start nodeexporter.service
fi

