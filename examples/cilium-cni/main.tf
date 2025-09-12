module "k3s" {
  source  = "marshallford/k3s/ansible"
  version = "0.2.7" # x-release-please-version

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
  }

  tokens = {
    server = "some-token"
    agent  = "some-token"
  }

  server_machines = {
    a = {
      name = "a"
      ssh = {
        address = "192.168.1.100"
      }
      config = {
        cluster_init = true
      }
    }
  }

  server_nodes_config = {
    flannel_backend        = "none"
    disable_network_policy = true,
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.k3s.server
    client_certificate     = module.k3s.ephemeral_credentials.client_certificate
    client_key             = module.k3s.ephemeral_credentials.client_key
    cluster_ca_certificate = module.k3s.ephemeral_credentials.cluster_ca_certificate
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.18.0"
  namespace  = "kube-system"

  set = [
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
  ]
}
