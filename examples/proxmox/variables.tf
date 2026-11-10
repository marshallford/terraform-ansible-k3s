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
  default  = "local"
  nullable = false
}

variable "proxmox_block_storage" {
  type     = string
  default  = "local-lvm"
  nullable = false
}

variable "proxmox_bridge" {
  type     = string
  default  = "vmbr0"
  nullable = false
}

variable "proxmox_nodes" {
  type = list(object({
    name              = string
    availability_zone = string
  }))
}

variable "region" {
  type     = string
  default  = "datacenter"
  nullable = false
}

variable "cluster_name" {
  type     = string
  default  = "terraform-ansible-k3s-example"
  nullable = false
}

variable "api_server_virtual_ip" {
  type     = string
  nullable = false
}

variable "api_server_virtual_router_id" {
  type     = number
  default  = 1
  nullable = false
}

variable "server_nodes" {
  type     = number
  default  = 3
  nullable = false
}

variable "agent_nodes" {
  type     = number
  default  = 1
  nullable = false
}
