# k3s Cluster Terraform Module

[![Terraform Registry](https://img.shields.io/badge/terraform-ansible--k3s-%23844FBA?logo=terraform&logoColor=%23844FBA)](https://registry.terraform.io/modules/marshallford/k3s/ansible/latest)
[![GitHub Release](https://img.shields.io/github/v/release/marshallford/terraform-ansible-k3s?sort=semver&display_name=release&logo=github)](https://github.com/marshallford/terraform-ansible-k3s/releases)

Provision and operate a Kubernetes cluster with the convenience of a CSP-managed Kubernetes service. Designed for homelabs, on-premises, and edge environments.

![Architecture diagram](/diagram.png "Architecture diagram")

## 📦 Features

1. **Deploys** [k3s](https://docs.k3s.io/), a single-binary Kubernetes distribution
2. **Employs** k3s' [air-gapped](https://docs.k3s.io/installation/airgap) installation method
3. **Implements** a virtual IP address with automatic failover for the Kubernetes API server (powered by [Keepalived](https://www.keepalived.org/))
4. **Delivers** a [highly available](https://docs.k3s.io/architecture#high-availability-k3s) control plane with load-balanced server nodes (powered by [HAProxy](https://www.haproxy.org/))
5. **Includes** built-in [SELinux support](https://docs.k3s.io/advanced#selinux-support) using the SELinux policy package
6. **Offers** curated [configuration options](https://docs.k3s.io/installation/configuration) including node taints/labels, cluster networking, and Kubernetes component flags
7. **Integrates** with k3s’ [auto-deploying manifests](https://docs.k3s.io/installation/packaged-components#auto-deploying-manifests-addons) and [registry configuration](https://docs.k3s.io/installation/private-registry) features
8. **Provides** recommendations for [CIS hardening](https://docs.k3s.io/security/hardening-guide) and [graceful node shutdown](https://kubernetes.io/docs/concepts/cluster-administration/node-shutdown/#graceful-node-shutdown), delivered via optional Terraform submodules
9. **Performs** in-place [upgrades](https://docs.k3s.io/upgrades/manual#upgrade-k3s-using-the-binary) with orchestrated node draining and optional [system upgrades](https://coreos.github.io/rpm-ostree/)
10. **Manages** day-2 node additions and [removals](https://docs.k3s.io/installation/uninstall)
11. **Facilitates** Kubernetes certificate [rotation](https://docs.k3s.io/cli/certificate#checking-expiration-dates)
12. **Enables** seamless Terraform-native [cluster access](https://docs.k3s.io/cluster-access), no manual steps required

## 🚀 Key Differentiators

1. **Cloud-agnostic by design** -- provisions clusters without dependencies on cloud services (e.g. Load Balancers, PKI, KMS)
2. **Day-2 friendly operations** -- avoids reliance on machine bootstrapping tools (e.g. Cloud-init, Ignition), simplifying troubleshooting and management at scale
3. **Self-contained architecture** -- eliminates the need for an external Ansible control plane (e.g. AWX/Ansible Tower)

## 📋 Requirements

### 🛠️ Terraform execution host/runner

1. [Terraform](https://developer.hashicorp.com/terraform/install) installed (version 1.12 or later)
2. [`ansible-navigator`](https://ansible.readthedocs.io/projects/navigator/installation/) installed (version 25.4.0 or later)
3. Container engine (`podman` or `docker`) with support for `amd64` or `arm64` images (Ansible execution environment)
4. Access to `github.com` to download k3s release artifact tarballs

### ⚙️ Machines (virtual or otherwise)

1. [Fedora CoreOS](https://fedoraproject.org/coreos/) 42 or later (`amd64`, `arm`, or `arm64` architecture)
2. Configured with a non-root [user](https://docs.fedoraproject.org/en-US/fedora-coreos/authentication/) with passwordless `sudo` access
3. Reachable via SSH from the Terraform execution host/runner
4. Network connectivity between all machines
5. Python 3 installed on the [host](https://docs.fedoraproject.org/en-US/fedora-coreos/os-extensions/) (required by Ansible)
6. Access to `quay.io` and the [Fedora repositories](https://docs.fedoraproject.org/en-US/quick-docs/fedora-repositories/) (via direct internet access, a configured proxy, or local mirror/container registry) for system upgrades and package downloads. Note: Using Zincati for automatic updates requires additional access.

## 🔍 Example

Additional [examples](/examples) available.

```terraform
module "k3s" {
  source  = "marshallford/k3s/ansible"

  ssh_private_keys = [
    {
      name = "example"
      data = var.private_key
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
      cluster_init = name == "a",
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

## ⚠️ Limitations

1. Only tested with `amd64` machines on an IPv4 network
2. SELinux package cannot be upgraded ([upstream issue](https://github.com/coreos/rpm-ostree/issues/2127))
3. Removal of the `cluster-init` server node is untested
4. Machines removed must be fully wiped or have their disks reprovisioned prior to rejoining the cluster
5. Terraform-managed machine resources must set lifecycle `create_before_destroy = true` to ensure correct ordering during node removal

## 🚧 To-do

- [ ] Ansible roles equivalent to Butane snippets
- [ ] Support for custom Ansible plays (pre, post, etc)
- [ ] Butane snippet for NTP
- [ ] Firewall rules
- [ ] Keepalived `max_auto_priority` option
- [ ] Assert podman version
- [ ] k3s token rotation
- [ ] Stop Zincati at start of playbook and start at the end
- [ ] Knownhosts management
