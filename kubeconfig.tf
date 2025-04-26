module "kubeconfig" {
  source = "./modules/kubeconfig"

  ansible_navigator_binary    = var.ansible_navigator_binary
  execution_environment_image = var.execution_environment_image
  ssh_private_keys            = var.ssh_private_keys
  cluster_reference           = ansible_navigator_run.this.id
  server                      = local.server
  server_machine              = one([for machine in var.server_machines : machine if try(machine.config.cluster_init, false)])
  persistent_outputs          = var.persistent_outputs
}

# output "cluster_credentials" {
#   value = module.kubeconfig.credentials
#   sensitive = true
#   ephemeral = true
# }

# output "kubeconfig_yaml" {
#   value = module.kubeconfig.yaml
#   sensitive = true
#   ephemeral = true
# }

output "persistent_cluster_credentials" {
  value     = module.kubeconfig.persistent_credentials
  sensitive = true
}

output "persistent_kubeconfig_yaml" {
  value     = module.kubeconfig.persistent_yaml
  sensitive = true
}
