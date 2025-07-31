# k3s Cluster Terraform Module

[![Terraform Registry](https://img.shields.io/badge/terraform-ansible--k3s-%23844FBA?logo=terraform&logoColor=%23844FBA)](https://registry.terraform.io/modules/marshallford/k3s/ansible/latest)
[![GitHub Release](https://img.shields.io/github/v/release/marshallford/terraform-ansible-k3s?sort=semver&display_name=release&logo=github)](https://github.com/marshallford/terraform-ansible-k3s/releases)

Deploy and manage a fully-featured Kubernetes cluster with the convenience of a managed cloud service. Ideal for homelab environments, on-premises deployments, and edge computing scenarios.

## Features

1. Single-binary Kubernetes distribution ([k3s](https://docs.k3s.io/)) with support for `amd64`, `arm`, and `arm64` architectures
2. [Air-gapped](https://docs.k3s.io/installation/airgap) installation using release artifact tarballs
3. [High-availability control plane](https://docs.k3s.io/architecture#high-availability-k3s) with multiple server nodes ([HAProxy](https://www.haproxy.org/))
4. Kubernetes API server [virtual IP](https://docs.k3s.io/architecture#fixed-registration-address-for-agent-nodes) and automatic failover ([Keepalived](https://www.keepalived.org/))
5. Installation of [SELinux](https://docs.k3s.io/advanced#selinux-support) policy package
6. Support for [auto-deploying manifests](https://docs.k3s.io/installation/packaged-components#auto-deploying-manifests-addons)
7. [Node and cluster configuration](https://docs.k3s.io/installation/configuration) guardrails and customization (node taints/labels, k3s component flags, etc)
8. In-place cluster [upgrades](https://docs.k3s.io/upgrades/manual#upgrade-k3s-using-the-binary) with proper node draining
9. System upgrades with [rpm-ostree](https://coreos.github.io/rpm-ostree/) including orchestrated node reboots
10. Dynamic node additions and [removals](https://docs.k3s.io/installation/uninstall)
11. Kubernetes client and server certificate [rotation](https://docs.k3s.io/cli/certificate#checking-expiration-dates)
12. [Cluster access](https://docs.k3s.io/cluster-access) from within Terraform -- no manual steps required

### Advantages over other solutions

1. Cloud-agnostic and does not require any cloud services (e.g. Load Balancers, PKI)
2. Does not use machine bootstrapping tools (e.g cloud-init, Ignition) which can complicate idempotency, error handling, and debugging
3. No need to install and maintain a separate Ansible control node (e.g. AWX, Ansible Tower)

## Requirements

### Terraform execution host/runner

1. [`ansible-navigator`](https://ansible.readthedocs.io/projects/navigator/installation/)
2. Container engine (`podman`, `docker`) to run the Ansible execution environment (EE)
3. GitHub.com must be accessible in order to download k3s release artifacts

### Machines (virtual or otherwise)

1. Fedora CoreOS (latest stable release)
2. Accessible via passwordless SSH from Terraform execution host/runner
3. A non-root user with passwordless `sudo` access

## Example

See the [examples](./examples) directory for complete k3s cluster configuration and deployment examples.

```terraform
module "k3s" {
  source  = "marshallford/k3s/ansible"

  ssh_private_keys = [
    {
      name = "example"
      data = file("~/.ssh/example")
    }
  ]

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
  }

  tokens = {
    server = "some-token"
    agent  = "some-token"
  }

  server_machines = { for name, addr in local.server_machines : name => {
    name = name
    ssh = {
      address = addr
    }
    config = {
      cluster_init = key == "a",
    }
  } }

  agent_machine_groups = {
    "example" = { for name, addr in local.agent_machines : name => {
      name = name
      ssh = {
        address = addr
      }
    } }
  }
}

provider "kubernetes" {
  host                   = module.k3s.server
  cluster_ca_certificate = module.k3s.ephemeral_credentials.cluster_ca_certificate
  client_certificate     = module.k3s.ephemeral_credentials.client_certificate
  client_key             = module.k3s.ephemeral_credentials.client_key
}
```

## Limitations

1. Only tested with `x86_64` machines on a IPv4 network
2. SELinux package cannot be upgraded ([upstream issue](https://github.com/coreos/rpm-ostree/issues/2127))
3. Removal of `cluster-init` server node not tested
4. Removed server nodes cannot be re-added without first destroying the machine or machine disk
5. Node removal requires `create_before_destroy = true` set on machine resource(s) for correct order of operations

## To-do

- [ ] Conditional Ansible roles equivalent to included butane snippets
- [ ] Support custom Ansible plays (before, after, etc)
- [ ] Butane snippet for NTP
- [ ] Add Firewall rules
- [ ] Explore Keepalived `max_auto_priority` option
- [ ] Assert podman version
- [ ] Simplify ansible handlers sharing across plays/roles
- [ ] Configuration for k3s node-ip and node-external-ip (haproxy/keepalived interface and address too)
- [ ] Token rotation
- [ ] Stop Zicanati at start of playbook and start at the end
- [ ] Examples: CIS hardening, kubeletConfiguration, custom CNI, registry
- [ ] Knownhost management
