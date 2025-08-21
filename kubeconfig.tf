resource "terraform_data" "cluster_created" {
  depends_on = [ansible_navigator_run.this]
}

module "kubeconfig" {
  source = "./modules/kubeconfig"

  ansible_navigator_binary    = var.ansible_navigator_binary
  execution_environment_image = var.execution_environment_image
  ssh_private_keys            = var.ssh_private_keys
  server_machine              = one([for machine in var.server_machines : machine if machine.config.cluster_init])
  block_type                  = var.kubeconfig_block_type
  cluster_reference           = terraform_data.cluster_created.id
  server                      = local.server
}
