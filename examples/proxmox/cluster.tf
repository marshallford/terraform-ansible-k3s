resource "random_password" "token" {
  for_each = toset(["agent", "server"])
  length   = 32
  special  = false
}

resource "time_rotating" "system_upgrade" {
  rotation_days = 30
}

module "k3s_cis_hardening" {
  source  = "marshallford/k3s/ansible//modules/cis-hardening"
  version = "0.2.12" # x-release-please-version
}

module "k3s_authentication_config" {
  source  = "marshallford/k3s/ansible//modules/authentication-config"
  version = "0.2.12" # x-release-please-version
  anonymous = {
    enabled = true
    conditions = [
      { path = "/livez" },
      { path = "/readyz" },
      { path = "/healthz" },
    ]
  }
}

locals {
  server_nodes_config_merged = merge(
    module.k3s_cis_hardening.server_nodes_config,
    module.k3s_authentication_config.server_nodes_config,
    {
      kube_apiserver_arg = merge(
        try(module.k3s_cis_hardening.server_nodes_config.kube_apiserver_arg, {}),
        try(module.k3s_authentication_config.server_nodes_config.kube_apiserver_arg, {})
      )
    }
  )
}

module "k3s" {
  source  = "marshallford/k3s/ansible"
  version = "0.2.12" # x-release-please-version

  ansible_navigator_binary = ".venv/bin/ansible-navigator"
  ssh_private_keys = [
    {
      name = "machine"
      data = tls_private_key.machine.private_key_openssh
    }
  ]

  api_server = {
    virtual_ip        = var.api_server_virtual_ip
    virtual_router_id = var.api_server_virtual_router_id
  }

  tokens = {
    agent  = random_password.token["agent"].result
    server = random_password.token["server"].result
  }

  server_machines = { for key, vm in proxmox_virtual_environment_vm.server : key => {
    name = key
    ssh = {
      address = vm.ipv4_addresses[1][0]
    }
    config = {
      cluster_init = key == "00",
      node_label = {
        "topology.kubernetes.io/region" = var.region
        "topology.kubernetes.io/zone"   = "${var.region}-${local.server_machines[key].availability_zone}"
      }
    }
  } }
  agent_machine_groups = {
    "primary" = { for key, vm in proxmox_virtual_environment_vm.agent : key => {
      name = key
      ssh = {
        address = vm.ipv4_addresses[1][0]
      }
      config = {
        node_label = {
          "topology.kubernetes.io/region" = var.region
          "topology.kubernetes.io/zone"   = "${var.region}-${local.agent_machines[key].availability_zone}"
        }
      }
    } }
  }
  all_nodes_config    = module.k3s_cis_hardening.all_nodes_config
  server_nodes_config = local.server_nodes_config_merged
  files               = merge(module.k3s_cis_hardening.files, module.k3s_authentication_config.files)
  kubelet_configs = [
    {
      apiVersion                      = "kubelet.config.k8s.io/v1beta1"
      kind                            = "KubeletConfiguration"
      shutdownGracePeriod             = "5m"
      shutdownGracePeriodCriticalPods = "1m"
    },
  ]
  system_upgrade_trigger = time_rotating.system_upgrade.id
  kubeconfig_block_type  = "data"
}

resource "kubernetes_namespace_v1" "example" {
  metadata {
    name = "terraform-ansible-k3s-example"
  }
}
