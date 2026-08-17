module "k3s_cis_hardening" {
  source = "../../modules/cis-hardening"
}

module "k3s" {
  source = "../../"

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
  }

  tokens = {
    server = "some-token"
    agent  = "some-token"
  }

  server_machines = {
    machines = {
      a = {
        name    = "a"
        address = "192.168.1.100"
      }
    }
  }

  all_nodes_config    = module.k3s_cis_hardening.all_nodes_config
  server_nodes_config = module.k3s_cis_hardening.server_nodes_config
  files               = module.k3s_cis_hardening.files
}
