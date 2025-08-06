# Kubeconfig

This submodule retrieves the k3s cluster admin credentials and a formatted kubeconfig by connecting to a k3s server machine.

## Example

```hcl
module "k3s_kubeconfig" {
  source = "marshallford/k3s/ansible//modules/kubeconfig"

  server_machine = {
    ssh = {
      host = "some-host"
    }
  }
  server = "https://example.com:6443"
}

provider "kubernetes" {
  host                   = module.k3s_kubeconfig.server
  cluster_ca_certificate = module.k3s_kubeconfig.credentials.cluster_ca_certificate
  client_certificate     = module.k3s_kubeconfig.credentials.client_certificate
  client_key             = module.k3s_kubeconfig.credentials.client_key
}
```
