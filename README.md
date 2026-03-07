# Raspberry Pi Home Kubernetes Cluster

![Build Status](https://img.shields.io/badge/build-manual%20validation-lightgrey)
![Kubernetes](https://img.shields.io/badge/kubernetes-v1.31-blue)

Infrastructure-as-code for a Raspberry Pi home Kubernetes cluster. The repo is mostly Kubernetes manifests plus bootstrap scripts for node prep, cluster init, and base service rollout.

## What is in this repo

- `bootstrap/`: node preparation, Kubernetes install/bootstrap, cluster population, helper scripts.
- `network/`: CNI manifests (Flannel and Calico variants).
- `metallb/`: MetalLB namespace/controller/config.
- `nginx/`: ingress controller and ingress resources.
- `dashboard/`, `pihole/`, `home-assistant/`, `trello-groomer/`, `tts-ui/`, `sthinds.io/`, `monitoring/`: app/service manifests.
- `gitlab-runner/`: GitLab Runner Helm values/install helper.
- `provision.ansible-playbook.yml`: legacy provisioning playbook (use cautiously).

## Prerequisites

- 1 control-plane Raspberry Pi and 1+ worker Pis on the same network.
- Ubuntu/Debian-based OS on nodes.
- Passwordless SSH from control plane to workers (used by `bootstrap/cluster_bootstrap.sh`).
- `sudo` access on nodes.
- `kubectl` on the control-plane node.
- Optional: `helm` for GitLab runner install.

## Install and Setup

1. Clone the repo on the control-plane node:

```bash
git clone git@github.com:sth144/pi-k8s-home-cluster.git
cd pi-k8s-home-cluster
```

2. Prepare each node (run on every Pi):

```bash
bash bootstrap/cluster_node_prepare.sh
bash bootstrap/cluster_install_docker.sh
bash bootstrap/cluster_install_k8s.sh
sudo reboot
```

3. Edit bootstrap node addresses before cluster init:

- File: `bootstrap/cluster_bootstrap.sh`
- Update `MASTER_IP`, `WORKER1_IP`, `WORKER2_IP` to match your network/hostnames.

4. Bootstrap the cluster from the control-plane node:

```bash
bash bootstrap/cluster_bootstrap.sh
```

5. Install one CNI plugin (Flannel example):

```bash
kubectl apply -f network/flannel/kube-flannel.0.26.yml
```

6. Populate core services in expected order:

```bash
bash bootstrap/cluster_populate.sh
```

## Run and Operations

- Check cluster health:

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

- Apply a single service update:

```bash
kubectl apply -f <path-to-manifest>
```

- Safer image upgrade workflow:

```bash
bash bootstrap/image_upgrade_workflow.sh plan
bash bootstrap/image_upgrade_workflow.sh validate
bash bootstrap/image_upgrade_workflow.sh apply <manifest...>
```

## Secrets and Local-Only Files

Do not commit real credentials. Use local files/placeholders for sensitive values such as:

- `gitlab-runner/.env.REGISTRATION_TOKEN`
- `pihole/.env`

Create/update Pi-hole secret from local env:

```bash
cd pihole
bash create-secret.sh
```

Install GitLab runner with local token:

```bash
cd gitlab-runner
bash helm_install.sh
```

## Validation

YAML and shell sanity checks:

```bash
# if yq is installed
find . -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0 -r yq e 'true' >/dev/null

bash -n bootstrap/*.sh
```

Optional manifest dry-run:

```bash
kubectl apply --dry-run=client -f <file>
```

## Destructive Reset (Use With Caution)

`bootstrap/cluster_reset.sh` is intentionally destructive (kube reset, docker cleanup, iptables flush, reboot). Only use it when you explicitly want to tear down a node.

## Build Status

This repo currently uses manual validation and dry-run checks rather than a committed CI workflow. The badge above reflects that current state.
