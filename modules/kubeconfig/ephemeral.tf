ephemeral "ansible_navigator_run" "this" {
  count                    = var.block_type == "ephemeral" ? 1 : 0
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
  ephemeral_credentials = try(jsondecode(ephemeral.ansible_navigator_run.this[0].artifact_queries.credentials.results[0]), null)
  ephemeral_kubeconfig_yaml = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = var.cluster_name
      cluster = {
        server                       = var.server
        "certificate-authority-data" = base64encode(try(local.ephemeral_credentials.cluster_ca_certificate, ""))
      }
    }]
    users = [{
      name = var.user_name
      user = {
        "client-certificate-data" = base64encode(try(local.ephemeral_credentials.client_certificate, ""))
        "client-key-data"         = base64encode(try(local.ephemeral_credentials.client_key, ""))
      }
    }]
    contexts = [{
      name = var.context_name
      context = {
        cluster = var.cluster_name
        user    = var.user_name
      }
    }]
    current-context = var.context_name
  })
}
