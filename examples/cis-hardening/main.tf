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

  server_group = {
    config = module.k3s_cis_hardening.server_config
    machines = {
      a = {
        name    = "a"
        address = "192.168.1.100"
      }
    }
  }

  agent_groups = {
    a = {
      config = module.k3s_cis_hardening.agent_config
      machines = {
        a = {
          name    = "a"
          address = "192.168.1.101"
        }
      }
    }
  }

  files = module.k3s_cis_hardening.files
}
