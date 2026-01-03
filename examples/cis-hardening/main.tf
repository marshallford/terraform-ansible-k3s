module "k3s_cis_hardening" {
  source  = "marshallford/k3s/ansible//modules/cis-hardening"
  version = "0.2.12" # x-release-please-version
}

module "k3s" {
  source  = "marshallford/k3s/ansible"
  version = "0.2.12" # x-release-please-version

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

  all_nodes_config    = module.k3s_cis_hardening.all_nodes_config
  server_nodes_config = module.k3s_cis_hardening.server_nodes_config
  files               = module.k3s_cis_hardening.files
}
