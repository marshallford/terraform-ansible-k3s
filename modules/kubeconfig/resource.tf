resource "ansible_navigator_run" "this" {
  count                    = var.block_type == "resource" ? 1 : 0
  ansible_navigator_binary = var.ansible_navigator_binary
  working_directory        = "${path.module}/ansible"
  playbook                 = local.playbook
  inventory                = local.inventory
  execution_environment = {
    enabled = var.execution_environment_enabled
    image   = var.execution_environment_image
  }
  ansible_options = {
    private_keys = var.ssh_private_keys
  }
  artifact_queries = local.artifact_queries
  timeouts = {
    read = "1m"
  }
}
