# Proxmox Example

This example demonstrates how to deploy a K3s cluster onto the Proxmox virtualization platform using the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider.

## Prerequisites

1. `docker`
2. `python3` with `uv`
3. `terraform`
4. One or more Proxmox hosts and the necessary [credentials](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#authentication)
5. Proxmox host(s) must have access to the internet to download the Fedora CoreOS image
6. The file level storage specified by the `proxmox_file_storage` variable must have the content type "snippets" enabled

## Notes

1. For demonstration purposes, this example relies on DHCP for virtual machine network configuration; in practice, static IPs or reserved DHCP leases should be used.
2. To ensure the example is at least somewhat portable to other Proxmox environments, no shared storage is assumed. In practice, shared file level storage should be used to store/distribute the Fedora CoreOS image across all hosts.
3. Machine names include the Proxmox VM ID, so a replaced VM joins the cluster as a new node and the old one is reset before its VM is destroyed.
4. Ignition only runs on first boot, so changes to the Ignition config don't replace running VMs. To roll a change out (or replace a machine), replace one machine's `random_id` per apply, e.g. `terraform apply -replace='random_id.server_ignition["00"]'`.

## Steps

1. Run `make` to install the `ansible-navigator` package into a Python virtual environment
2. Copy `terraform.auto.tfvars.example` to `terraform.auto.tfvars` and update the values
3. Run `terraform init` and `terraform apply`
4. Retrieve the cluster admin kubeconfig from Terraform (e.g. `terraform output --raw kubeconfig_yaml > kubeconfig.yaml`) and use the kubeconfig file to access the cluster (e.g. `KUBECONFIG=kubeconfig.yaml kubectl get nodes`)
