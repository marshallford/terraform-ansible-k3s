terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = ">= 0.27.0, < 1.0.0"
    }
  }
}

locals {
  inventory = yamlencode({
    all = {
      vars = {
        ansible_ssh_common_args    = "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile={{ ansible_ssh_known_hosts_file }}"
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

# TODO use existing known hosts
# ephemeral "ansible_navigator_run" "this" {
#   ansible_navigator_binary = var.ansible_navigator_binary
#   working_directory        = "${path.module}/ansible"
#   playbook                 = local.playbook
#   inventory                = local.inventory
#   execution_environment = {
#     image = var.execution_environment_image
#   }
#   ansible_options = {
#     ssh_private_keys = var.ssh_private_keys
#   }
#   artifact_queries = {
#     "credentials" = {
#       jq_filter = local.artifact_query
#     }
#   }
#   timeouts = {
#     open = "1m"
#   }
# }

# TODO use existing known hosts
data "ansible_navigator_run" "this" {
  count                    = var.persistent_outputs ? 1 : 0
  ansible_navigator_binary = var.ansible_navigator_binary
  working_directory        = "${path.module}/ansible"
  playbook                 = local.playbook
  inventory                = local.inventory
  execution_environment = {
    image = var.execution_environment_image
  }
  ansible_options = {
    ssh_private_keys = var.ssh_private_keys
  }
  artifact_queries = {
    "credentials" = {
      jq_filter = local.artifact_query
    }
  }
  timeouts = {
    read = "1m"
  }
}

locals {
  # cluster_credentials = jsondecode(ephemeral.ansible_navigator_run.this.artifact_queries.credentials.results[0])
  # kubeconfig_yaml = yamlencode({
  #   apiVersion = "v1"
  #   kind       = "Config"
  #   clusters = [{
  #     name = "default"
  #     cluster = {
  #       server                       = var.server
  #       "certificate-authority-data" = base64encode(local.cluster_credentials.certificate_authority)
  #     }
  #   }]
  #   users = [{
  #     name = "default"
  #     user = {
  #       "client-certificate-data" = base64encode(local.cluster_credentials.client_certificate)
  #       "client-key-data"         = base64encode(local.cluster_credentials.client_key)
  #     }
  #   }]
  #   contexts = [{
  #     name = "default"
  #     context = {
  #       cluster = "default"
  #       user    = "default"
  #     }
  #   }]
  #   current-context = "default"
  # })
  persistent_cluster_credentials = try(jsondecode(data.ansible_navigator_run.this[0].artifact_queries.credentials.results[0]), null)
  persistent_kubeconfig_yaml = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = "default"
      cluster = {
        server                       = var.server
        "certificate-authority-data" = base64encode(try(local.persistent_cluster_credentials.certificate_authority, ""))
      }
    }]
    users = [{
      name = "default"
      user = {
        "client-certificate-data" = base64encode(try(local.persistent_cluster_credentials.client_certificate, ""))
        "client-key-data"         = base64encode(try(local.persistent_cluster_credentials.client_key, ""))
      }
    }]
    contexts = [{
      name = "default"
      context = {
        cluster = "default"
        user    = "default"
      }
    }]
    current-context = "default"
  })
}
