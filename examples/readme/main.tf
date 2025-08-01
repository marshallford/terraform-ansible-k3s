# Note: This example is not complete and is used for formatting purposes only.

module "k3s" {
  source  = "marshallford/k3s/ansible"
  version = "0.2.1" # x-release-please-version

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

locals {
  server_machines = {
    a = "192.168.1.100"
    b = "192.168.1.101"
    c = "192.168.1.102"
  }

  agent_machines = {
    x = "192.168.1.103"
    y = "192.168.1.104"
  }
}
