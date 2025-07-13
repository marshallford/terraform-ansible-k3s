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
  default     = "ghcr.io/marshallford/terraform-ansible-k3s:v0.1.1" # x-release-please-version
  nullable    = true
  description = "Name of the execution environment container image."
}

variable "ssh_private_keys" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  description = "SSH private keys used to connect to the machines (name=contents)."
}

variable "cluster_reference" {
  type        = string
  nullable    = true
  default     = null
  description = "Used to create an implicit dependency on the cluster."
}

variable "server" {
  type        = string
  nullable    = false
  description = "Address of the cluster."
}

variable "server_machine" {
  type = object({
    ssh = object({
      user    = optional(string, "core")
      address = string
      port    = optional(number, 22)
    })
  })
  nullable    = false
  description = "Machine that has been configured as a server node."
}

variable "persistent_outputs" {
  type        = bool
  nullable    = false
  default     = true # TODO switch to false when bug is fixed
  description = "Retrieve cluster kubeconfig yaml and credentials via data source in addition to an ephemeral resource. Results in sensitive values being stored in the state file."
}
