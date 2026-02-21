# AGENTS.md

## Project Purpose
This repository contains infrastructure-as-code for a Raspberry Pi home Kubernetes cluster. Most changes are Kubernetes manifests (`.yaml`/`.yml`) plus a small set of bootstrap shell scripts.

## Repository Structure
- `bootstrap/`: Node bootstrap and cluster lifecycle scripts (`cluster_install_*`, `cluster_bootstrap.sh`, `cluster_populate.sh`, `cluster_reset.sh`).
- `network/`: CNI manifests (Flannel and Calico variants).
- `metallb/`: MetalLB namespace/controller/config.
- `nginx/`: NGINX deployment and ingress resources.
- `dashboard/`: Kubernetes dashboard + admin user resources.
- `helm/`: RBAC manifest used by Helm/Tiller-era setup.
- `gitlab-runner/`: GitLab runner Helm values + install helper script.
- `home-assistant/`, `pihole/`, `trello-groomer/`, `tts-ui/`, `sthinds.io/`, `monitoring/`: App/service-specific manifests.
- `provision.ansible-playbook.yml`: Ansible-based provisioning flow (legacy/inconsistent formatting; treat carefully).

## Working Conventions
- Keep manifests scoped to one subsystem folder; do not move files between subsystems unless explicitly requested.
- Prefer minimal, targeted edits over broad refactors.
- Preserve existing naming and file style in each folder (`.yaml` vs `.yml`, resource names, labels).
- When adding resources for an existing app, place them in that app directory and keep ingress resources under `nginx/ingress/` unless told otherwise.

## Sensitive Data Rules
- Do not introduce or commit real secrets/tokens.
- Files currently containing sensitive values (for example `gitlab-runner/.env.REGISTRATION_TOKEN`, `pihole/.env`, and generated join-token artifacts) should be treated as local-only.
- If a task needs credentials, use placeholders and clearly mark follow-up steps.

## Validation Before Finishing Changes
Run lightweight checks when relevant:

```bash
# YAML syntax/lint check (if yq is available)
rg --files -g '*.yaml' -g '*.yml' | xargs -r yq e 'true' >/dev/null

# Shell syntax check for edited scripts
bash -n bootstrap/*.sh
```

If cluster access is available and requested, validate manifests with:

```bash
kubectl apply --dry-run=client -f <file>
```

## Deployment and Ordering Notes
`bootstrap/cluster_populate.sh` represents expected apply order for core services:
1. `metallb/`
2. `nginx/deployment/` then `nginx/ingress/`
3. `helm/rbac-config.yaml`
4. app manifests (`pihole`, `dashboard`, `trello-groomer`, etc.)

When asked to add new foundational networking components, ensure ordering still makes sense relative to MetalLB and ingress.

## Out-of-Scope / Caution Areas
- Avoid destructive lifecycle operations (`cluster_reset.sh`, mass `kubeadm reset`, docker image/container removal) unless explicitly requested.
- `provision.ansible-playbook.yml` appears partially malformed; avoid broad edits unless the task is specifically to repair that playbook.

## Typical Agent Tasks
- Add or update Kubernetes manifests for one service.
- Update ingress rules and related service exposure.
- Adjust bootstrap scripts for node/cluster setup.
- Keep changes reviewable and include exact file paths touched in summaries.
