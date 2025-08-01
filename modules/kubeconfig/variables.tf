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
  default     = "ghcr.io/marshallford/terraform-ansible-k3s:v0.2.1" # x-release-please-version
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

variable "block_type" {
  type     = string
  nullable = false
  default  = "ephemeral"
  validation {
    condition     = contains(["ephemeral", "data", "resource"], var.block_type)
    error_message = "The block_type must be either 'ephemeral', 'data', or 'resource'."
  }
  description = "Terraform block type to use for retrieving cluster kubeconfig and credentials."
}

variable "cluster_reference" {
  type        = string
  nullable    = true
  default     = null
  description = "Cluster reference to ensure correct dependency ordering."
}

variable "server" {
  type        = string
  nullable    = false
  description = "Address of the cluster."
}

variable "cluster_name" {
  type        = string
  nullable    = false
  default     = "default"
  description = "Name of the cluster for the kubeconfig."
}

variable "user_name" {
  type        = string
  nullable    = false
  default     = "default"
  description = "Name of the user for the kubeconfig."
}

variable "context_name" {
  type        = string
  nullable    = false
  default     = "default"
  description = "Name of the context for the kubeconfig."

}
