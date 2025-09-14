locals {
  server = "https://example.com:6443"
}

module "k3s_kubeconfig" {
  source  = "marshallford/k3s/ansible//modules/kubeconfig"
  version = "0.2.8" # x-release-please-version

  server_machine = {
    ssh = {
      address = "some-host"
    }
  }
  server     = local.server
  block_type = "data"
}

provider "kubernetes" {
  host                   = local.server
  cluster_ca_certificate = module.k3s_kubeconfig.credentials.cluster_ca_certificate
  client_certificate     = module.k3s_kubeconfig.credentials.client_certificate
  client_key             = module.k3s_kubeconfig.credentials.client_key
}

resource "kubernetes_namespace_v1" "example" {
  metadata {
    name = "example"
  }
}
