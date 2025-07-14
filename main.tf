terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = ">= 0.31.0, < 1.0.0"
    }
  }
}

locals {
  inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args     = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile={{ ansible_ssh_known_hosts_file }}"
        ansible_python_interpreter  = "/usr/bin/python3"
        k3s_api_server              = var.api_server
        k3s_version                 = var.k3s_version
        k3s_selinux_version         = var.selinux_version
        k3s_tokens                  = var.tokens
        k3s_files                   = var.files
        k3s_registries_config       = var.registries_config
        k3s_cleanup                 = var.cleanup
        system_upgrade_trigger      = var.system_upgrade_trigger
        haproxy_container_image     = var.haproxy_container_image
        haproxy_container_image_tag = var.haproxy_container_image_tag
        k3s_all_nodes_config = { for k, v in merge(var.all_nodes_config, {
          kubelet_arg    = [for k, v in var.all_nodes_config.kubelet_arg : "${k}=${v}"]
          kube_proxy_arg = [for k, v in var.all_nodes_config.kube_proxy_arg : "${k}=${v}"]
        }) : replace(k, "_", "-") => v if v != null && v != [] }
        k3s_server_nodes_config = { for k, v in merge(var.server_nodes_config, {
          etcd_arg                          = [for k, v in var.server_nodes_config.etcd_arg : "${k}=${v}"]
          kube_apiserver_arg                = [for k, v in var.server_nodes_config.kube_apiserver_arg : "${k}=${v}"]
          kube_scheduler_arg                = [for k, v in var.server_nodes_config.kube_scheduler_arg : "${k}=${v}"]
          kube_controller_manager_arg       = [for k, v in var.server_nodes_config.kube_controller_manager_arg : "${k}=${v}"]
          kube_cloud_controller_manager_arg = [for k, v in var.server_nodes_config.kube_cloud_controller_manager_arg : "${k}=${v}"]
          kubelet_arg                       = [for k, v in var.server_nodes_config.kubelet_arg : "${k}=${v}"]
          kube_proxy_arg                    = [for k, v in var.server_nodes_config.kube_proxy_arg : "${k}=${v}"]
        }) : replace(k, "_", "-") => v if v != null && v != [] }
      }
      children = {
        servers = {
          hosts = { for machine in var.server_machines : "server-${machine.name}" => {
            ansible_user = machine.ssh.user
            ansible_host = machine.ssh.address
            ansible_port = machine.ssh.port
            k3s_node_config = { for k, v in merge(machine.config, {
              node_name  = coalesce(machine.config.node_name, "server-${machine.name}"),
              node_label = [for k, v in machine.config.node_label : "${k}=${v}"]
              node_taint = [for k, v in machine.config.node_taint : "${k}=${v}"]
            }) : replace(k, "_", "-") => v if v != null && v != [] }
          } }
          vars = {
            k3s_role      = "server"
            k3s_manifests = var.manifests
          }
        }
        agents = {
          vars = { k3s_role = "agent" }
          children = { for group_name, group_machines in var.agent_machine_groups : "agents_${group_name}" => {
            hosts = { for machine in group_machines : "agent-${group_name}-${machine.name}" => {
              ansible_user = machine.ssh.user
              ansible_host = machine.ssh.address
              ansible_port = machine.ssh.port
              k3s_node_config = { for k, v in merge(machine.config, {
                node_name  = coalesce(machine.config.node_name, "agent-${group_name}-${machine.name}"),
                node_label = [for k, v in machine.config.node_label : "${k}=${v}"]
                node_taint = [for k, v in machine.config.node_taint : "${k}=${v}"]
              }) : replace(k, "_", "-") => v if v != null && v != [] }
            } }
          } }
        }
      }
    }
  })
  roles_files_hashes = {
    for file_path in fileset("${path.module}/ansible/roles", "**/*.yaml") :
    file_path => filebase64sha512("${path.module}/ansible/roles/${file_path}")
  }
  server = "https://${coalesce(try(var.api_server.hosts[0], null), var.api_server.virtual_ip)}"
}

resource "ansible_navigator_run" "this" {
  ansible_navigator_binary = var.ansible_navigator_binary
  working_directory        = "${path.module}/ansible"
  playbook                 = file("${path.module}/ansible/playbook.yaml")
  inventory                = local.inventory
  execution_environment = {
    enabled = var.execution_environment_enabled
    image   = var.execution_environment_image
  }
  ansible_options = {
    ssh_private_keys = var.ssh_private_keys
  }
  artifact_queries = {
    "stdout" = {
      jq_filter = ".stdout"
    }
  }
  triggers = {
    run = {
      roles               = base64sha256(jsonencode(local.roles_files_hashes))
      config              = filebase64sha512("${path.module}/ansible/ansible.cfg")
      rotate_certificates = local.certificates_ok ? null : plantimestamp()
    }
    known_hosts = {
      server_machines      = base64sha256(jsonencode({ for k, v in var.server_machines : k => v.ssh }))
      agent_machine_groups = base64sha256(jsonencode({ for group_name, group_machines in var.agent_machine_groups : group_name => { for k, v in group_machines : k => v.ssh } }))
    }
  }
  timeouts = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
  run_on_destroy   = var.reset_on_destroy
  destroy_playbook = file("${path.module}/ansible/destroy_playbook.yaml")
}
