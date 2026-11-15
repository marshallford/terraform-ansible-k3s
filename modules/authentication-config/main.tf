terraform {
  required_version = ">= 1.15.0"
}

output "server_config" {
  type = object({
    kube_apiserver_arg = map(string)
  })
  value = {
    kube_apiserver_arg = {
      "authentication-config" = "K3S_FILES_DIR/authentication-config.yaml"
    }
  }
  description = "K3s configuration options for server_group.config."
}

output "files" {
  type = map(object({
    groups  = list(string)
    content = string
  }))
  value = {
    "authentication-config.yaml" = { groups = ["server"], content = yamlencode(merge({
      apiVersion = "apiserver.config.k8s.io/v1"
      kind       = "AuthenticationConfiguration"
    }, { anonymous = var.anonymous, jwt = var.jwt })) }
  }
  description = "Authentication configuration files for the files variable, selecting the server group."
}
