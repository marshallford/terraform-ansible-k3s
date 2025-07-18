terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = ">= 0.31.0, < 1.0.0"
    }
  }
}

locals {
  inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args    = provider::ansible::ssh_args(true)
        ansible_python_interpreter = "/usr/bin/python3"
        cluster_reference          = var.cluster_reference
      }
      hosts = {
        server = {
          ansible_user = var.server_machine.ssh.user
          ansible_host = var.server_machine.ssh.address
          ansible_port = var.server_machine.ssh.port
        }
      }
    }
  })
  playbook       = file("${path.module}/ansible/playbook.yaml")
  artifact_query = <<-EOT
  .plays[] | select(.name=="Kubeconfig") |
  .tasks[] | select(.task=="Set kubeconfig facts") |
  .res.ansible_facts
  EOT
}
