module "k3s_cluster" {
  source = "marshallford/k3s/ansible"

  ssh_private_keys = {
    "example" = file("~/.ssh/example")
  }

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
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

  tokens = {
    "server" = "some-token"
    "agent"  = "some-token"
  }
}

provider "kubernetes" {
  host                   = module.k3s_cluster.server
  client_certificate     = module.k3s_cluster.persistent_cluster_credentials.client_certificate
  client_key             = module.k3s_cluster.persistent_cluster_credentials.client_key
  cluster_ca_certificate = module.k3s_cluster.persistent_cluster_credentials.certificate_authority
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
