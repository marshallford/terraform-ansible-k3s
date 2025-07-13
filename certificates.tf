locals {
  certificates_inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args    = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile={{ ansible_ssh_known_hosts_file }}"
        ansible_python_interpreter = "/usr/bin/python3"
      }
      children = {
        servers = {
          hosts = { for machine in var.server_machines : "server-${machine.name}" => {
            ansible_user = machine.ssh.user
            ansible_host = machine.ssh.address
            ansible_port = machine.ssh.port
          } }
        }
        agents = {
          children = { for group_name, group_machines in var.agent_machine_groups : "agents_${group_name}" => {
            hosts = { for machine in group_machines : "agent-${group_name}-${machine.name}" => {
              ansible_user = machine.ssh.user
              ansible_host = machine.ssh.address
              ansible_port = machine.ssh.port
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
    ssh_private_keys = var.ssh_private_keys
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
    read = "1m"
  }
}

locals {
  certificates_ok_results = data.ansible_navigator_run.certificates.artifact_queries.certificates_ok.results
  certificates_ok = (jsondecode(local.certificates_ok_results[0]) == null ?
  true : alltrue([for result in local.certificates_ok_results : jsondecode(result)]))
}
