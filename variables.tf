variable "ansible_navigator_binary" {
  type        = string
  default     = null
  nullable    = true
  description = "Path to the ansible-navigator binary. By default $PATH is searched."
}

variable "execution_environment_enabled" {
  type        = bool
  default     = true
  nullable    = false
  description = "Enable or disable the use of an execution environment."
}

variable "execution_environment_image" {
  type        = string
  default     = "ghcr.io/marshallford/terraform-ansible-k3s:v0.8.0" # x-release-please-version
  nullable    = true
  description = "Name of the execution environment container image."
}

variable "playbook_stdout_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Enable the playbook_stdout output. It is large and changes every run."
}

variable "ssh_private_keys" {
  type = list(object({
    name = string
    data = string
  }))
  default     = []
  nullable    = false
  sensitive   = true
  description = "SSH private keys used to connect to the machines."
}

variable "api_server" {
  type = object({
    virtual_ip        = string
    virtual_router_id = number
    hosts             = optional(list(string), [])
  })
  nullable = false
  validation {
    condition     = can(cidrnetmask("${var.api_server.virtual_ip}/32"))
    error_message = "The virtual_ip must be an IPv4 address."
  }
  validation {
    condition     = floor(var.api_server.virtual_router_id) == var.api_server.virtual_router_id && var.api_server.virtual_router_id >= 1 && var.api_server.virtual_router_id <= 255
    error_message = "The virtual_router_id must be a whole number between 1 and 255."
  }
  description = "Keepalived configuration for API server VIP and additional TLS SAN entries for API server certificate."
}

variable "tokens" {
  type = object({
    server = string
    agent  = string
  })
  nullable  = false
  sensitive = true
  validation {
    condition     = length(var.tokens.server) > 0 && length(var.tokens.agent) > 0
    error_message = "The server and agent tokens must not be empty."
  }
  description = "Shared secret used to join a server or agent to cluster."
}

variable "server_machines" {
  type = object({
    ssh = optional(object({
      user = optional(string, "core")
      port = optional(number, 22)
    }), {})
    firewall_rules = optional(list(string), [])
    machines = map(object({
      name    = string
      address = string
      config = optional(object({
        node_name        = optional(string)
        node_ip          = optional(string)
        node_external_ip = optional(string)
        node_label       = optional(map(string), {})
        node_taint       = optional(map(string), {})
      }), {})
    }))
  })
  nullable = false
  validation {
    condition     = length(var.server_machines.machines) > 0
    error_message = "At least one server machine must be defined."
  }
  validation {
    condition     = length(distinct([for machine in var.server_machines.machines : machine.name])) == length(var.server_machines.machines)
    error_message = "Each server machine must have a unique name."
  }
  validation {
    condition = alltrue([
      for machine in var.server_machines.machines :
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", coalesce(machine.config.node_name, "server-${machine.name}"))) &&
      length(coalesce(machine.config.node_name, "server-${machine.name}")) <= 63
    ])
    error_message = "Each server node name (config.node_name, or 'server-<name>' when unset) must be a valid RFC1123 DNS label: max 63 characters, lowercase alphanumeric or '-', must start and end with alphanumeric."
  }
  validation {
    condition = length(distinct([
      for machine in var.server_machines.machines : coalesce(machine.config.node_name, "server-${machine.name}")
    ])) == length(var.server_machines.machines)
    error_message = "Each server node name (config.node_name, or 'server-<name>' when unset) must be unique."
  }
  validation {
    condition = alltrue([
      for machine in var.server_machines.machines :
      can(cidrnetmask("${coalesce(machine.config.node_ip, machine.address)}/32")) &&
      can(cidrnetmask("${coalesce(machine.config.node_external_ip, machine.address)}/32"))
    ])
    error_message = "Each server node IP and external IP (config.node_ip and config.node_external_ip, or address when unset) must be a single IPv4 address."
  }
  validation {
    condition     = floor(var.server_machines.ssh.port) == var.server_machines.ssh.port && var.server_machines.ssh.port >= 1 && var.server_machines.ssh.port <= 65535
    error_message = "The ssh port must be a whole number between 1 and 65535."
  }
  validation {
    condition     = alltrue([for rule in var.server_machines.firewall_rules : trimspace(rule) != "" && !strcontains(rule, "\n")])
    error_message = "Each server firewall rule must be a single, non-empty line."
  }
  description = "Machines to be configured as server nodes. The ssh user/port apply to every server machine, including when retrieving the kubeconfig. The firewall_rules are extra nftables input rules, e.g. \"tcp dport 443 accept\", where the last match wins, including over the built-in rules; [\"accept\"] disables filtering."
}

variable "agent_machine_groups" {
  type = map(object({
    ssh = optional(object({
      user = optional(string, "core")
      port = optional(number, 22)
    }), {})
    firewall_rules = optional(list(string), [])
    machines = map(object({
      name    = string
      address = string
      config = optional(object({
        node_name        = optional(string)
        node_ip          = optional(string)
        node_external_ip = optional(string)
        node_label       = optional(map(string), {})
        node_taint       = optional(map(string), {})
      }), {})
    }))
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for group in var.agent_machine_groups :
      length(distinct([for machine in group.machines : machine.name])) == length(group.machines)
    ])
    error_message = "Each agent machine must have a unique name within its group."
  }
  validation {
    condition = alltrue(flatten([
      for group_name, group in var.agent_machine_groups : [
        for machine in group.machines :
        can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", coalesce(machine.config.node_name, "agent-${group_name}-${machine.name}"))) &&
        length(coalesce(machine.config.node_name, "agent-${group_name}-${machine.name}")) <= 63
      ]
    ]))
    error_message = "Each agent node name (config.node_name, or 'agent-<group>-<name>' when unset) must be a valid RFC1123 DNS label: max 63 characters, lowercase alphanumeric or '-', must start and end with alphanumeric."
  }
  validation {
    condition = length(distinct(concat(
      [for machine in var.server_machines.machines : coalesce(machine.config.node_name, "server-${machine.name}")],
      flatten([for group_name, group in var.agent_machine_groups : [for machine in group.machines : coalesce(machine.config.node_name, "agent-${group_name}-${machine.name}")]]),
    ))) == length(var.server_machines.machines) + sum(concat([0], [for group in var.agent_machine_groups : length(group.machines)]))
    error_message = "Each agent node name (config.node_name, or 'agent-<group>-<name>' when unset) must be unique across all server and agent nodes."
  }
  validation {
    condition = alltrue(flatten([
      for group in var.agent_machine_groups : [
        for machine in group.machines : alltrue([
          for ip in concat(
            split(",", coalesce(machine.config.node_ip, machine.address)),
            split(",", coalesce(machine.config.node_external_ip, machine.address)),
          ) : can(cidrhost("${ip}/32", 0))
        ])
      ]
    ]))
    error_message = "Each agent node IP and external IP (config.node_ip and config.node_external_ip, or address when unset) must be one or more comma-separated IP addresses."
  }
  validation {
    condition = alltrue(flatten([
      for group in var.agent_machine_groups : [
        for machine in group.machines :
        length(split(",", coalesce(machine.config.node_ip, machine.address))) == 1 || (
          length(split(",", coalesce(machine.config.node_ip, machine.address))) == 2 &&
          length([for ip in split(",", coalesce(machine.config.node_ip, machine.address)) : ip if can(cidrnetmask("${ip}/32"))]) == 1
        )
      ]
    ]))
    error_message = "Each agent node IP (config.node_ip, or address when unset) must be a single IP address or a dual-stack pair of one IPv4 and one IPv6 address, as the kubelet requires."
  }
  validation {
    condition     = alltrue([for group in var.agent_machine_groups : floor(group.ssh.port) == group.ssh.port && group.ssh.port >= 1 && group.ssh.port <= 65535])
    error_message = "The ssh port of each agent group must be a whole number between 1 and 65535."
  }
  validation {
    condition     = alltrue(flatten([for group in var.agent_machine_groups : [for rule in group.firewall_rules : trimspace(rule) != "" && !strcontains(rule, "\n")]]))
    error_message = "Each agent group firewall rule must be a single, non-empty line."
  }
  description = "Machines to be configured as agent nodes, grouped. The ssh user/port and firewall_rules (as for server_machines) apply to every machine within a group."
}

variable "k3s_version" {
  type     = string
  default  = "1.37.2+k3s1"
  nullable = false
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[0-9A-Za-z.-]+)?(\\+[0-9A-Za-z.-]+)?$", var.k3s_version))
    error_message = "The k3s_version must be a semantic version without a 'v' prefix (e.g. '1.37.2+k3s1')."
  }
  description = "The version of K3s to install."
}

variable "k3s_selinux_version" {
  type     = string
  default  = "1.6.1"
  nullable = false
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[0-9A-Za-z.-]+)?(\\+[0-9A-Za-z.-]+)?$", var.k3s_selinux_version))
    error_message = "The k3s_selinux_version must be a semantic version without a 'v' prefix (e.g. '1.6.1')."
  }
  description = "The version of K3s SELinux package to install."
}

variable "keepalived_container_image" {
  type        = string
  default     = "docker.io/osixia/keepalived"
  nullable    = false
  description = "Keepalived container image used for VRRP VIP failover."
}

variable "keepalived_container_image_tag" {
  type        = string
  default     = "2.4.3"
  nullable    = false
  description = "Keepalived container image tag used for VRRP VIP failover."
}

variable "haproxy_container_image" {
  type        = string
  default     = "docker.io/library/haproxy"
  nullable    = false
  description = "HAProxy container image used for API server load balancing."
}

variable "haproxy_container_image_tag" {
  type        = string
  default     = "3.4.7"
  nullable    = false
  description = "HAProxy container image tag used for API server load balancing."
}

# https://docs.k3s.io/cli/agent
variable "all_nodes_config" {
  type = object({
    protect_kernel_defaults = optional(bool)
    selinux                 = optional(bool)
    kubelet_arg             = optional(map(string), {})
    kube_proxy_arg          = optional(map(string), {})
  })
  default     = {}
  nullable    = false
  description = "Configuration options that apply to all nodes."
}

# https://docs.k3s.io/cli/server
variable "server_nodes_config" {
  type = object({
    secrets_encryption                = optional(bool)
    secrets_encryption_provider       = optional(string)
    cluster_cidr                      = optional(string)
    service_cidr                      = optional(string)
    flannel_backend                   = optional(string)
    egress_selector_mode              = optional(string)
    default_local_storage_path        = optional(string)
    disable                           = optional(list(string))
    disable_scheduler                 = optional(bool)
    disable_cloud_controller          = optional(bool)
    disable_kube_proxy                = optional(bool)
    disable_network_policy            = optional(bool)
    disable_helm_controller           = optional(bool)
    etcd_arg                          = optional(map(string), {})
    kube_apiserver_arg                = optional(map(string), {})
    kube_scheduler_arg                = optional(map(string), {})
    kube_controller_manager_arg       = optional(map(string), {})
    kube_cloud_controller_manager_arg = optional(map(string), {})
    kubelet_arg                       = optional(map(string), {})
    kube_proxy_arg                    = optional(map(string), {})
    disable_agent                     = optional(bool)
  })
  default     = {}
  nullable    = false
  description = "Configuration options that apply to server nodes."
}

variable "manifests" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "Auto deploying manifests (filename=contents). Removing manifests will not delete the corresponding resources from the cluster."
}

variable "files" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "Files copied to the machines to be referenced in configuration (filename=contents). The string 'K3S_FILES_DIR' can be referenced in configurations to point to the directory where the files are copied."
}

# https://docs.k3s.io/installation/configuration#kubelet-configuration-files
variable "kubelet_configs" {
  type     = any
  default  = []
  nullable = false
  validation {
    condition     = can(slice(var.kubelet_configs, 0, 0)) && alltrue([for v in var.kubelet_configs : can(keys(v))])
    error_message = "The kubelet_configs variable must be a list of objects or maps."
  }
  validation {
    condition = !can(slice(var.kubelet_configs, 0, 0)) || alltrue([
      for config in var.kubelet_configs :
      try(config.apiVersion, null) != null
    ])
    error_message = "Each kubelet configuration must contain an 'apiVersion' key."
  }
  validation {
    condition = !can(slice(var.kubelet_configs, 0, 0)) || alltrue([
      for config in var.kubelet_configs :
      try(config.kind, null) == "KubeletConfiguration"
    ])
    error_message = "Each kubelet configuration must contain 'kind: KubeletConfiguration'."
  }
  description = "Configure kubelet via drop-in configuration files."
}

# https://rancher.com/docs/k3s/latest/en/installation/private-registry/
variable "registries_config" {
  type     = any
  default  = {}
  nullable = false
  validation {
    condition     = can(keys(var.registries_config))
    error_message = "The registries_config variable must be an object or map."
  }
  description = "Registry configuration to be used by K3s when generating the containerd configuration."
}

variable "drain_options" {
  type = object({
    deletion_fallback = optional(bool, false)
    eviction_timeout  = optional(string, "30m")
    deletion_timeout  = optional(string, "10m")
  })
  default  = {}
  nullable = false
  validation {
    condition     = can(timeadd(plantimestamp(), var.drain_options.eviction_timeout))
    error_message = "The eviction_timeout must be a valid duration (e.g. '10m', '30s', '1h30m')."
  }
  validation {
    condition     = can(timeadd(plantimestamp(), var.drain_options.deletion_timeout))
    error_message = "The deletion_timeout must be a valid duration (e.g. '10m', '30s', '1h30m')."
  }
  description = "Node drain options."
}

variable "system_upgrade_trigger" {
  type        = string
  default     = ""
  nullable    = false
  description = "Trigger machine system upgrades (with reboot)."
}

variable "reset_on_destroy" {
  type        = bool
  default     = false
  nullable    = false
  description = "Stop services (Keepalived, HAProxy, K3s) and stop all containers on destroy."
}

variable "cleanup" {
  type        = bool
  default     = true
  nullable    = false
  description = "Remove unused K3s binaries, images and SELinux packages from machines. Disable when performing frequent downgrades/upgrades."
}

variable "kubeconfig_block_type" {
  type     = string
  default  = "ephemeral"
  nullable = false
  validation {
    condition     = contains(["ephemeral", "data", "resource"], var.kubeconfig_block_type)
    error_message = "The kubeconfig_block_type must be either 'ephemeral', 'data', or 'resource'."
  }
  description = "Terraform block type to use for retrieving cluster kubeconfig and credentials."
}
