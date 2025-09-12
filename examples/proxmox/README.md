# Proxmox Example

This complete example demonstrates how to deploy a k3s cluster onto the Proxmox virtualization platform using the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider.

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

## Steps

1. Run `make` to install the `ansible-navigator` package into a Python virtual environment
2. Copy `terraform.auto.tfvars.example` to `terraform.auto.tfvars` and update the values
3. Run `terraform init` and `terraform apply`
