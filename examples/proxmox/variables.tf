variable "proxmox_endpoint" {
  type     = string
  nullable = false
}

variable "proxmox_username" {
  type     = string
  default  = "root@pam"
  nullable = false
}

variable "proxmox_password" {
  type     = string
  nullable = false
}

variable "proxmox_file_storage" {
  type     = string
  nullable = false
  default  = "local"
}

variable "proxmox_block_storage" {
  type     = string
  nullable = false
  default  = "local-lvm"
}

variable "proxmox_bridge" {
  type     = string
  nullable = false
  default  = "vmbr0"
}

variable "proxmox_nodes" {
  type = list(object({
    name              = string
    availability_zone = string
  }))
}

variable "region" {
  type     = string
  nullable = false
  default  = "datacenter"
}

variable "cluster_name" {
  type     = string
  nullable = false
  default  = "terraform-ansible-k3s-example"
}

variable "api_server_virtual_ip" {
  type     = string
  nullable = false
}

variable "api_server_virtual_router_id" {
  type     = number
  nullable = false
  default  = 1
}

variable "server_nodes" {
  type     = number
  nullable = false
  default  = 3
}

variable "agent_nodes" {
  type     = number
  nullable = false
  default  = 1
}
