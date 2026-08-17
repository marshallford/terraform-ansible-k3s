locals {
  interface          = "ens18"
  timezone           = "Etc/UTC"
  ssh_authorized_key = "ssh-ed25519 ... example"

  common_snippets = [
    module.butane_python.snippet,
    module.butane_qemu_ga.snippet,
    module.butane_ssh_authorized_key.snippet,
    module.butane_count_me_opt_out.snippet,
    module.butane_timezone.snippet,
  ]
}

module "butane_hostname" {
  source = "../../modules/butane-hostname"

  hostname = "example"
}

module "butane_python" {
  source = "../../modules/butane-python"
}

module "butane_qemu_ga" {
  source = "../../modules/butane-qemu-ga"
}

module "butane_ssh_authorized_key" {
  source = "../../modules/butane-ssh-authorized-key"

  ssh_authorized_key = local.ssh_authorized_key
}

module "butane_count_me_opt_out" {
  source = "../../modules/butane-count-me-opt-out"
}

module "butane_timezone" {
  source = "../../modules/butane-timezone"

  timezone = local.timezone
}

# networking -- pick one per machine, they configure the same interface

module "butane_dhcp" {
  source = "../../modules/butane-dhcp"

  interface = local.interface
}

module "butane_static_ip" {
  source = "../../modules/butane-static-ip"

  interface      = local.interface
  ip             = "192.168.1.100"
  prefix         = 24
  gateway        = "192.168.1.1"
  nameservers    = ["192.168.1.1"]
  search_domains = ["example.test"]
  static_routes = [
    {
      address = "10.0.0.0"
      prefix  = 8
      gateway = "192.168.1.254"
    }
  ]
}

# machine updates -- pick one per machine, they are competing Zincati strategies

module "butane_zincati_disable" {
  source = "../../modules/butane-zincati-disable"
}

module "butane_zincati_periodic" {
  source = "../../modules/butane-zincati-periodic"

  time_zone = local.timezone
  windows = [
    {
      days           = ["Sat", "Sun"]
      start_time     = "03:00"
      length_minutes = 120
    }
  ]
}

module "butane_zincati_immediate" {
  source = "../../modules/butane-zincati-immediate"
}

# machine profiles -- common snippets plus one networking and one update choice

data "ct_config" "disabled_updates" {
  content = module.butane_hostname.snippet
  snippets = concat(local.common_snippets, [
    module.butane_dhcp.snippet,
    module.butane_zincati_disable.snippet,
  ])
  strict       = true
  pretty_print = true
}

data "ct_config" "periodic_updates" {
  content = module.butane_hostname.snippet
  snippets = concat(local.common_snippets, [
    module.butane_static_ip.snippet,
    module.butane_zincati_periodic.snippet,
  ])
  strict       = true
  pretty_print = true
}

data "ct_config" "immediate_updates" {
  content = module.butane_hostname.snippet
  snippets = concat(local.common_snippets, [
    module.butane_dhcp.snippet,
    module.butane_zincati_immediate.snippet,
  ])
  strict       = true
  pretty_print = true
}
