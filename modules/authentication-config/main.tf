terraform {
  required_version = ">= 1.12.0"
}

output "server_nodes_config" {
  value = {
    kube_apiserver_arg = {
      "authentication-config" = "K3S_FILES_DIR/authentication-config.yaml"
    }
  }
  description = "Configuration options that apply to server nodes."
}

output "files" {
  value = {
    "authentication-config.yaml" = yamlencode(merge({
      apiVersion = "apiserver.config.k8s.io/v1"
      kind       = "AuthenticationConfiguration"
    }, { anonymous = var.anonymous, jwt = var.jwt }))
  }
  description = "Files copied to machines."
}
