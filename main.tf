terraform {
  required_version = ">= 1.15.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = ">= 0.39.0, < 1.0.0"
    }
  }
}

locals {
  inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args        = provider::ansible::ssh_args(true)
        ansible_python_interpreter     = "/usr/bin/python3"
        k3s_version                    = var.k3s_version
        k3s_selinux_version            = var.k3s_selinux_version
        k3s_server                     = "https://${var.api_server.virtual_ip}:${local.api_server_port}"
        k3s_tls_san                    = concat([var.api_server.virtual_ip], var.api_server.hosts)
        k3s_server_token               = var.tokens.server
        k3s_agent_token                = var.tokens.agent
        k3s_files                      = var.files
        k3s_kubelet_configs            = var.kubelet_configs
        k3s_registries_config          = var.registries_config
        k3s_cleanup                    = var.cleanup
        k3s_drain_options              = var.drain_options
        k3s_https_listen_port          = local.k3s_https_listen_port
        system_upgrade_trigger         = var.system_upgrade_trigger
        keepalived_container_image     = var.keepalived_container_image
        keepalived_container_image_tag = var.keepalived_container_image_tag
        haproxy_container_image        = var.haproxy_container_image
        haproxy_container_image_tag    = var.haproxy_container_image_tag
        firewall_node_rules            = local.firewall_node_rules
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
        bootstrap_server = {
          hosts = { "server-${local.first_server_machine.name}" = {} }
        }
        servers = {
          hosts = { for machine in var.server_machines.machines : "server-${machine.name}" => {
            ansible_host                      = machine.address
            haproxy_keepalived_unicast_src_ip = local.server_node_ips["server-${machine.name}"]
            haproxy_keepalived_unicast_peers  = [for name, ip in local.server_node_ips : ip if name != "server-${machine.name}"]
            k3s_node_config = { for k, v in merge(machine.config, {
              node_name        = coalesce(machine.config.node_name, "server-${machine.name}"),
              node_ip          = local.server_node_ips["server-${machine.name}"],
              node_external_ip = coalesce(machine.config.node_external_ip, machine.address),
              node_label       = [for k, v in machine.config.node_label : "${k}=${v}"]
              node_taint       = [for k, v in machine.config.node_taint : "${k}=${v}"]
            }) : replace(k, "_", "-") => v if v != null && v != [] }
          } }
          vars = {
            ansible_user                          = var.server_machines.ssh.user
            ansible_port                          = var.server_machines.ssh.port
            k3s_role                              = "server"
            k3s_manifests                         = var.manifests
            haproxy_keepalived_virtual_ip_address = var.api_server.virtual_ip
            haproxy_keepalived_virtual_router_id  = var.api_server.virtual_router_id
            haproxy_backend_servers               = [for name, ip in local.server_node_ips : [name, ip]]
            haproxy_listen_port                   = local.api_server_port
            haproxy_backend_port                  = local.k3s_https_listen_port
            firewall_k3s_rules                    = concat(local.firewall_k3s_rules, ["tcp dport ${local.api_server_port} accept comment \"K3s API server\""])
            firewall_rules                        = var.server_machines.firewall_rules
          }
        }
        agents = {
          vars = {
            k3s_role           = "agent"
            firewall_k3s_rules = local.firewall_k3s_rules
          }
          children = { for group_name, group in var.agent_machine_groups : "agents_${group_name}" => {
            vars = {
              ansible_user   = group.ssh.user
              ansible_port   = group.ssh.port
              firewall_rules = group.firewall_rules
            }
            hosts = { for machine in group.machines : "agent-${group_name}-${machine.name}" => {
              ansible_host = machine.address
              k3s_node_config = { for k, v in merge(machine.config, {
                node_name        = coalesce(machine.config.node_name, "agent-${group_name}-${machine.name}"),
                node_ip          = coalesce(machine.config.node_ip, machine.address),
                node_external_ip = coalesce(machine.config.node_external_ip, machine.address),
                node_label       = [for k, v in machine.config.node_label : "${k}=${v}"]
                node_taint       = [for k, v in machine.config.node_taint : "${k}=${v}"]
              }) : replace(k, "_", "-") => v if v != null && v != [] }
            } }
          } }
        }
      }
    }
  })
  roles_files_hashes = {
    for file_path in fileset("${path.module}/ansible/roles", "**/*.{yaml,j2}") :
    file_path => filebase64sha512("${path.module}/ansible/roles/${file_path}")
  }
  server               = "https://${coalesce(try(var.api_server.hosts[0], null), var.api_server.virtual_ip)}:${local.api_server_port}"
  server_node_ips      = { for machine in var.server_machines.machines : "server-${machine.name}" => coalesce(machine.config.node_ip, machine.address) }
  first_server_machine = one([for machine in var.server_machines.machines : machine if machine.name == sort([for m in var.server_machines.machines : m.name])[0]])
  immutable = {
    api_server_virtual_ip        = var.api_server.virtual_ip
    api_server_virtual_router_id = var.api_server.virtual_router_id
    k3s_selinux_version          = var.k3s_selinux_version
  }
  api_server_port       = 6443
  k3s_https_listen_port = 8443
  # Trusting nodes and the pod/service networks wholesale keeps any CNI working.
  # TODO drop the VIP (flannel may use it for VXLAN) once keepalived > 2.4.3
  # marks /32 VIPs deprecated.
  firewall_node_addresses = distinct(flatten(concat(
    [var.api_server.virtual_ip],
    [for machine in var.server_machines.machines : [local.server_node_ips["server-${machine.name}"], coalesce(machine.config.node_external_ip, machine.address)]],
    [for group in var.agent_machine_groups : [for machine in group.machines : concat(
      split(",", coalesce(machine.config.node_ip, machine.address)),
      split(",", coalesce(machine.config.node_external_ip, machine.address)),
    )]],
  )))
  firewall_node_rules = [for family, addresses in {
    ip  = [for address in local.firewall_node_addresses : address if !strcontains(address, ":")]
    ip6 = [for address in local.firewall_node_addresses : address if strcontains(address, ":")]
  } : "${family} saddr { ${join(", ", addresses)} } accept comment \"K3s nodes\"" if length(addresses) > 0]
  firewall_cluster_cidrs = [for cidr in flatten([
    split(",", coalesce(var.server_nodes_config.cluster_cidr, "10.42.0.0/16")),
    split(",", coalesce(var.server_nodes_config.service_cidr, "10.43.0.0/16")),
  ]) : trimspace(cidr)]
  firewall_k3s_rules = concat(
    [for family, cidrs in {
      ip  = [for cidr in local.firewall_cluster_cidrs : cidr if !strcontains(cidr, ":")]
      ip6 = [for cidr in local.firewall_cluster_cidrs : cidr if strcontains(cidr, ":")]
    } : "${family} saddr { ${join(", ", cidrs)} } accept comment \"K3s pod and service networks\"" if length(cidrs) > 0],
    ["meta l4proto { tcp, udp } th dport ${lookup(var.server_nodes_config.kube_apiserver_arg, "service-node-port-range", "30000-32767")} accept comment \"K3s NodePorts\""],
  )
}

resource "terraform_data" "immutable" {
  input = local.immutable
  lifecycle {
    ignore_changes = [input]
    postcondition {
      condition     = alltrue([for key, value in local.immutable : try(self.output[key], value) == value])
      error_message = "These values cannot be changed after the cluster is created: ${join(", ", [for key, value in local.immutable : key if try(self.output[key], value) != value])}."
    }
  }
}

# Makes callers' machines create_before_destroy, so removed ones are reset before they're destroyed.
resource "terraform_data" "machines" {
  input = {
    servers = keys(var.server_machines.machines)
    agents  = { for name, group in var.agent_machine_groups : name => keys(group.machines) }
  }
  lifecycle {
    create_before_destroy = true
  }
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
    private_keys = var.ssh_private_keys
  }
  artifact_queries = merge(var.playbook_stdout_enabled ? { stdout = { jq_filter = ".stdout" } } : {}, {
    "summary" = {
      jq_filter = <<-EOT
      def task_name: ((.task_path // "") | capture("/roles/(?<role>[^/]+)/").role // null) as $role
        | if $role then "\($role) : \(.task)" else .task end;

      [.plays[].tasks[] | select(.__result != "In progress") | .name = task_name] as $tasks
      | ($tasks | map(select(.host != "localhost"))) as $node_tasks
      | {
        changed_per_host: ($node_tasks | group_by(.host) | map({key: .[0].host, value: map(select(.__changed)) | length}) | from_entries),
        changed_tasks: ($node_tasks | map(select(.__changed)) | group_by(.name) | map({key: .[0].name, value: length}) | from_entries),
        slowest_tasks: ($tasks | group_by(.name) | map({task: .[0].name, host_seconds: map(.duration // 0) | add | round}) | sort_by(-.host_seconds) | .[:10]),
      }
      EOT
    }
  })
  triggers = {
    run = {
      roles               = base64sha256(jsonencode(local.roles_files_hashes))
      config              = filebase64sha512("${path.module}/ansible/ansible.cfg")
      rotate_certificates = local.certificates_ok ? null : plantimestamp()
    }
    known_hosts = base64sha256(jsonencode(concat(
      [for machine in var.server_machines.machines : "${machine.address}:${var.server_machines.ssh.port}"],
      flatten([for group in var.agent_machine_groups : [for machine in group.machines : "${machine.address}:${group.ssh.port}"]]),
    )))
  }
  timeouts = {
    create = "2h"
    update = "4h"
    delete = "1h"
  }
  run_on_destroy   = var.reset_on_destroy
  destroy_playbook = file("${path.module}/ansible/destroy_playbook.yaml")
}
