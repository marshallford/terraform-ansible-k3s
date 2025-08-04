# Note: This example is not complete and is used for formatting purposes only.

module "k3s_cis_hardening" {
  source = "marshallford/k3s/ansible//modules/cis-hardening"
}

module "k3s" {
  source = "marshallford/k3s/ansible"

  # ...

  all_nodes_config    = module.k3s_cis_hardening.all_nodes_config
  server_nodes_config = module.k3s_cis_hardening.server_nodes_config
  files               = module.k3s_cis_hardening.files
}
