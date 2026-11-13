run "admission_plugins_default" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }

  assert {
    condition     = output.server_nodes_config.kube_apiserver_arg["enable-admission-plugins"] == "NodeRestriction,EventRateLimit,DenyServiceExternalIPs"
    error_message = "Unexpected admission plugins: ${output.server_nodes_config.kube_apiserver_arg["enable-admission-plugins"]}"
  }
}

run "admission_plugins_deny_service_external_ips_disabled" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }

  variables {
    deny_service_external_ips = false
  }

  assert {
    condition     = output.server_nodes_config.kube_apiserver_arg["enable-admission-plugins"] == "NodeRestriction,EventRateLimit"
    error_message = "Unexpected admission plugins: ${output.server_nodes_config.kube_apiserver_arg["enable-admission-plugins"]}"
  }
}
