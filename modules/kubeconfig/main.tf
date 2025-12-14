terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = ">= 0.35.0, < 1.0.0"
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
        k3s_server                 = var.server
        k3s_cluster_name           = var.cluster_name
        k3s_user_name              = var.user_name
        k3s_context_name           = var.context_name
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
  playbook = file("${path.module}/ansible/playbook.yaml")
  artifact_queries = {
    facts = {
      jq_filter = <<-EOT
      .plays[] | select(.name=="Kubeconfig") |
      .tasks[] | select(.task=="Set kubeconfig facts") |
      .res.ansible_facts
      EOT
    }
  }
}
