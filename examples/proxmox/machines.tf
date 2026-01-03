resource "proxmox_virtual_environment_download_file" "fcos" {
  for_each                = toset([for node in var.proxmox_nodes : node.name])
  content_type            = "iso"
  datastore_id            = var.proxmox_file_storage
  file_name               = "k8s-${var.cluster_name}-fedora-coreos-43.20251120.3.0-proxmoxve.x86_64.img"
  node_name               = each.value
  url                     = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/43.20251120.3.0/x86_64/fedora-coreos-43.20251120.3.0-proxmoxve.x86_64.qcow2.xz"
  checksum                = "56391f7a92792c932179ea089ef6f2bbc30e3f031caf584eabb27e7fbf2175fd"
  checksum_algorithm      = "sha256"
  decompression_algorithm = "zst"
}

resource "tls_private_key" "machine" {
  algorithm = "ED25519"
}

locals {
  server_machines = { for i in range(var.server_nodes) : format("%02d", i) => {
    full_name         = "k8s-${var.cluster_name}-server-${format("%02d", i)}"
    proxmox_node      = var.proxmox_nodes[i % length(var.proxmox_nodes)].name
    availability_zone = var.proxmox_nodes[i % length(var.proxmox_nodes)].availability_zone
  } }
  agent_machines = { for i in range(var.agent_nodes) : format("%02d", i) => {
    full_name         = "k8s-${var.cluster_name}-agent-${format("%02d", i)}"
    proxmox_node      = var.proxmox_nodes[i % length(var.proxmox_nodes)].name
    availability_zone = var.proxmox_nodes[i % length(var.proxmox_nodes)].availability_zone
  } }
}

module "server_butane_hostname" {
  for_each = local.server_machines
  source   = "marshallford/k3s/ansible//modules/butane-hostname"
  version  = "0.2.11" # x-release-please-version

  hostname = each.value.full_name
}

module "agent_butane_hostname" {
  for_each = local.agent_machines
  source   = "marshallford/k3s/ansible//modules/butane-hostname"
  version  = "0.2.11" # x-release-please-version

  hostname = each.value.full_name
}

module "butane_python" {
  source  = "marshallford/k3s/ansible//modules/butane-python"
  version = "0.2.11" # x-release-please-version
}

module "butane_keepalived" {
  source  = "marshallford/k3s/ansible//modules/butane-keepalived"
  version = "0.2.11" # x-release-please-version
}

module "butane_qemu_ga" {
  source  = "marshallford/k3s/ansible//modules/butane-qemu-ga"
  version = "0.2.11" # x-release-please-version
}

module "butane_ssh_authorized_key" {
  source  = "marshallford/k3s/ansible//modules/butane-ssh-authorized-key"
  version = "0.2.11" # x-release-please-version

  ssh_authorized_key = tls_private_key.machine.public_key_openssh
}

module "butane_dhcp" {
  source  = "marshallford/k3s/ansible//modules/butane-dhcp"
  version = "0.2.11" # x-release-please-version

  interface = "ens18"
}

module "butane_zincati_disable" {
  source  = "marshallford/k3s/ansible//modules/butane-zincati-disable"
  version = "0.2.11" # x-release-please-version
}

data "ct_config" "server" {
  for_each = local.server_machines
  content  = module.server_butane_hostname[each.key].snippet
  snippets = [
    module.butane_python.snippet,
    module.butane_keepalived.snippet,
    module.butane_qemu_ga.snippet,
    module.butane_ssh_authorized_key.snippet,
    module.butane_dhcp.snippet,
    module.butane_zincati_disable.snippet,
  ]
  strict       = true
  pretty_print = true
}

data "ct_config" "agent" {
  for_each = local.agent_machines
  content  = module.agent_butane_hostname[each.key].snippet
  snippets = [
    module.butane_python.snippet,
    module.butane_qemu_ga.snippet,
    module.butane_ssh_authorized_key.snippet,
    module.butane_dhcp.snippet,
    module.butane_zincati_disable.snippet,
  ]
  strict       = true
  pretty_print = true
}

resource "proxmox_virtual_environment_file" "server_ignition" {
  for_each     = data.ct_config.server
  content_type = "snippets"
  datastore_id = var.proxmox_file_storage
  node_name    = local.server_machines[each.key].proxmox_node

  source_raw {
    data      = each.value.rendered
    file_name = "${local.server_machines[each.key].full_name}.ign"
  }
}

resource "proxmox_virtual_environment_file" "agent_ignition" {
  for_each     = data.ct_config.agent
  content_type = "snippets"
  datastore_id = var.proxmox_file_storage
  node_name    = local.agent_machines[each.key].proxmox_node

  source_raw {
    data      = each.value.rendered
    file_name = "${local.agent_machines[each.key].full_name}.ign"
  }
}

resource "proxmox_virtual_environment_vm" "server" {
  for_each  = local.server_machines
  name      = each.value.full_name
  node_name = each.value.proxmox_node
  machine   = "q35"

  agent {
    enabled = true
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = 4
    type  = "x86-64-v3"
    flags = ["+aes"]
  }

  memory {
    dedicated = 4 * 1024
  }

  disk {
    datastore_id = var.proxmox_block_storage
    file_id      = proxmox_virtual_environment_download_file.fcos[each.value.proxmox_node].id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  initialization {
    datastore_id      = var.proxmox_block_storage
    user_data_file_id = proxmox_virtual_environment_file.server_ignition[each.key].id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "proxmox_virtual_environment_vm" "agent" {
  for_each  = local.agent_machines
  name      = each.value.full_name
  node_name = each.value.proxmox_node
  machine   = "q35"

  agent {
    enabled = true
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = 4
    type  = "x86-64-v3"
    flags = ["+aes"]
  }

  memory {
    dedicated = 2 * 1024
  }

  disk {
    datastore_id = var.proxmox_block_storage
    file_id      = proxmox_virtual_environment_download_file.fcos[each.value.proxmox_node].id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  initialization {
    datastore_id      = var.proxmox_block_storage
    user_data_file_id = proxmox_virtual_environment_file.agent_ignition[each.key].id
  }

  lifecycle {
    create_before_destroy = true
  }
}
