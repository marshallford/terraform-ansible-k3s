locals {
  certificates_inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args    = provider::ansible::ssh_args(true)
        ansible_python_interpreter = "/usr/bin/python3"
      }
      children = {
        servers = {
          vars = {
            ansible_user = var.server_machines.ssh.user
            ansible_port = var.server_machines.ssh.port
          }
          hosts = { for machine in var.server_machines.machines : "server-${machine.name}" => {
            ansible_host = machine.address
          } }
        }
        agents = {
          children = { for group_name, group in var.agent_machine_groups : "agents_${group_name}" => {
            vars = {
              ansible_user = group.ssh.user
              ansible_port = group.ssh.port
            }
            hosts = { for machine in group.machines : "agent-${group_name}-${machine.name}" => {
              ansible_host = machine.address
            } }
          } }
        }
      }
    }
  })
}

data "ansible_navigator_run" "certificates" {
  ansible_navigator_binary = var.ansible_navigator_binary
  working_directory        = "${path.module}/ansible"
  playbook                 = file("${path.module}/ansible/certificates_playbook.yaml")
  inventory                = local.certificates_inventory
  execution_environment = {
    enabled = var.execution_environment_enabled
    image   = var.execution_environment_image
  }
  ansible_options = {
    private_keys = var.ssh_private_keys
  }
  artifact_queries = {
    "certificates_ok" = {
      jq_filter = <<-EOT
      .plays[] | select(.name=="Check cluster certificates") |
      .tasks[] | select(.task=="Set certificate status fact") |
      .res.ansible_facts.k3s_certificates_ok
      EOT
    },
  }
  timeouts = {
    read = "5m"
  }
}

locals {
  certificates_ok_results = data.ansible_navigator_run.certificates.artifact_queries.certificates_ok.results
  certificates_ok = alltrue([
    for result in local.certificates_ok_results : coalesce(jsondecode(result), true)
  ])
}
