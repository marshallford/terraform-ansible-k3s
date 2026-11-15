mock_provider "ansible" {}

variables {
  api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 1 }
  tokens     = { server = "server", agent = "agent" }
}

run "admission_plugins_default" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }

  assert {
    condition     = output.server_config.kube_apiserver_arg["enable-admission-plugins"] == "NodeRestriction,EventRateLimit,DenyServiceExternalIPs"
    error_message = "Unexpected admission plugins: ${output.server_config.kube_apiserver_arg["enable-admission-plugins"]}"
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
    condition     = output.server_config.kube_apiserver_arg["enable-admission-plugins"] == "NodeRestriction,EventRateLimit"
    error_message = "Unexpected admission plugins: ${output.server_config.kube_apiserver_arg["enable-admission-plugins"]}"
  }
}

run "cis_hardening_outputs" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }
}

run "main_module_wiring" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_group = { config = run.cis_hardening_outputs.server_config, machines = { "00" = { name = "00", address = "192.0.2.10" } } }
    agent_groups = { a = { config = run.cis_hardening_outputs.agent_config, machines = { "00" = { name = "00", address = "192.0.2.20" } } } }
    files        = run.cis_hardening_outputs.files
  }

  assert {
    condition     = keys(yamldecode(ansible_navigator_run.this.inventory).all.children.servers.vars.k3s_files) == ["admission-control.yaml", "audit.yaml"]
    error_message = "Server machines must get the CIS hardening files."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_a.vars.k3s_files == {}
    error_message = "Agent machines must not get the server-only CIS hardening files."
  }

  assert {
    condition = alltrue([
      for config in [
        yamldecode(ansible_navigator_run.this.inventory).all.children.servers.hosts["server-00"].k3s_node_config,
        yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_a.hosts["agent-a-00"].k3s_node_config,
      ] : config["selinux"] && config["protect-kernel-defaults"] && contains(config["kubelet-arg"], "seccomp-default=true")
    ])
    error_message = "Server and agent machines must get the CIS hardening node options."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.servers.hosts["server-00"].k3s_node_config["secrets-encryption"]
    error_message = "Server machines must get the CIS hardening server options."
  }
}
