resource "terraform_data" "cluster_created" {
  input      = var.api_server.virtual_ip
  depends_on = [ansible_navigator_run.this]
}

module "kubeconfig" {
  source = "./modules/kubeconfig"

  ansible_navigator_binary    = var.ansible_navigator_binary
  execution_environment_image = var.execution_environment_image
  ssh_private_keys            = var.ssh_private_keys
  server_machine = {
    ssh     = var.server_machines.ssh
    address = terraform_data.cluster_created.output
  }
  block_type = var.kubeconfig_block_type
  server     = local.server
}
