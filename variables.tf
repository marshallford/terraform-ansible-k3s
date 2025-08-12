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
  default     = "ghcr.io/marshallford/terraform-ansible-k3s:v0.2.4" # x-release-please-version
  nullable    = true
  description = "Name of the execution environment container image."
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
    condition     = var.api_server.virtual_router_id >= 1 && var.api_server.virtual_router_id <= 255
    error_message = "The virtual_router_id must be between 1 and 255."
  }
  description = "Keepalived configuration for API server VIP and additional TLS SAN entries for API server certificate."
}

variable "tokens" {
  type = object({
    server = string
    agent  = string
  })
  nullable    = false
  sensitive   = true
  description = "Shared secret used to join a server or agent to cluster."
}

variable "server_machines" {
  type = map(object({
    name = string
    ssh = object({
      user    = optional(string, "core")
      address = string
      port    = optional(number, 22)
    })
    config = optional(object({
      cluster_init = optional(bool, false)
      node_name    = optional(string)
      node_label   = optional(map(string), {})
      node_taint   = optional(map(string), {})
    }), {})
  }))
  nullable = false
  validation {
    condition     = length(var.server_machines) > 0
    error_message = "At least one server machine must be defined."
  }
  validation {
    condition     = length([for server in var.server_machines : server if server.config.cluster_init]) == 1
    error_message = "Exactly one server machine must have cluster_init set to 'true'."
  }
  validation {
    condition = alltrue([
      for machine in var.server_machines :
      machine.config.node_name == null ||
      (can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", machine.config.node_name)) && try(length(machine.config.node_name), 0) <= 63)
    ])
    error_message = "The node_name must be a valid RFC1123 DNS label: max 63 characters, lowercase alphanumeric or '-', must start and end with alphanumeric."
  }
  description = "Machines to be configured as server nodes."
}

variable "agent_machine_groups" {
  type = map(map(object({
    name = string
    ssh = object({
      user    = optional(string, "core")
      address = string
      port    = optional(number, 22)
    })
    config = optional(object({
      node_name  = optional(string)
      node_label = optional(map(string), {})
      node_taint = optional(map(string), {})
    }), {})
  })))
  nullable = false
  default  = {}
  validation {
    condition = alltrue([
      for machines in var.agent_machine_groups :
      alltrue([
        for machine in machines :
        machine.config.node_name == null ||
        (can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", machine.config.node_name)) && try(length(machine.config.node_name), 0) <= 63)
      ])
    ])
    error_message = "The node_name must be a valid RFC1123 DNS label: max 63 characters, lowercase alphanumeric or '-', must start and end with alphanumeric."
  }
  description = "Machines to be configured as agent nodes."
}

variable "k3s_version" {
  type     = string
  nullable = false
  validation {
    condition     = var.k3s_version == null || can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+.*$", var.k3s_version))
    error_message = "The k3s_version must be a valid semantic version starting with x.y.z (e.g. '1.30.0') without a 'v' prefix."
  }
  default     = "1.33.3+k3s1"
  description = "The version of k3s to install."
}

variable "selinux_version" {
  type     = string
  nullable = false
  validation {
    condition     = var.selinux_version == null || can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+.*$", var.selinux_version))
    error_message = "The selinux_version must be a valid semantic version starting with x.y.z (e.g. '1.6.0') without a 'v' prefix."
  }
  default     = "1.6.1"
  description = "The version of k3s SELinux package to install."
}

variable "haproxy_container_image" {
  type        = string
  nullable    = false
  default     = "docker.io/library/haproxy"
  description = "HAProxy container image used for API server load balancing."
}

variable "haproxy_container_image_tag" {
  type        = string
  nullable    = false
  default     = "3.2.3"
  description = "HAProxy container image tag used for API server load balancing."
}

# https://docs.k3s.io/cli/agent
variable "all_nodes_config" {
  type = object({
    protect_kernel_defaults = optional(bool)
    selinux                 = optional(bool)
    kubelet_arg             = optional(map(any), {})
    kube_proxy_arg          = optional(map(any), {})
  })
  nullable    = false
  default     = {}
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
    etcd_arg                          = optional(map(any), {})
    kube_apiserver_arg                = optional(map(any), {})
    kube_scheduler_arg                = optional(map(any), {})
    kube_controller_manager_arg       = optional(map(any), {})
    kube_cloud_controller_manager_arg = optional(map(any), {})
    kubelet_arg                       = optional(map(any), {})
    kube_proxy_arg                    = optional(map(any), {})
    disable_agent                     = optional(bool)
  })
  nullable    = false
  default     = {}
  description = "Configuration options that apply to server nodes."
}

variable "manifests" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Auto deploying manifests (filename=contents). Removing manifests will not delete the corresponding resources from the cluster."
}

variable "files" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Files copied to the machines to be referenced in configuration (filename=contents). The string 'K3S_FILES_DIR' can be referenced in configurations to point to the directory where the files are copied."
}

# https://docs.k3s.io/installation/configuration#kubelet-configuration-files
variable "kubelet_configs" {
  type     = list(map(any))
  nullable = false
  default  = []
  validation {
    condition = alltrue([
      for config in var.kubelet_configs :
      try(config.apiVersion, null) != null
    ])
    error_message = "Each kubelet configuration must contain an 'apiVersion' key."
  }
  validation {
    condition = alltrue([
      for config in var.kubelet_configs :
      try(config.kind, null) == "KubeletConfiguration"
    ])
    error_message = "Each kubelet configuration must contain 'kind: KubeletConfiguration'."
  }
  description = "Configure kubelet via drop-in configuration files."
}

# https://rancher.com/docs/k3s/latest/en/installation/private-registry/
variable "registries_config" {
  type        = any
  nullable    = false
  default     = {}
  description = "Registry configuration to be used by k3s when generating the containerd configuration."
}

variable "system_upgrade_trigger" {
  type        = string
  nullable    = false
  default     = ""
  description = "Trigger machine system upgrades (with reboot)."
}

variable "reset_on_destroy" {
  type        = bool
  nullable    = false
  default     = false
  description = "Stop services (Keepalived, HAProxy, k3s) and stop all containers on destroy."
}

variable "cleanup" {
  type        = bool
  nullable    = false
  default     = true
  description = "Remove unused k3s binaries, images and selinux packages from machines. Disable when performing frequent downgrades/upgrades."
}

variable "kubeconfig_block_type" {
  type     = string
  nullable = false
  default  = "ephemeral"
  validation {
    condition     = contains(["ephemeral", "data", "resource"], var.kubeconfig_block_type)
    error_message = "The kubeconfig_block_type must be either 'ephemeral', 'data', or 'resource'."
  }
  description = "Terraform block type to use for retrieving cluster kubeconfig and credentials."
}
