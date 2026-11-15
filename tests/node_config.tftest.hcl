mock_provider "ansible" {}

variables {
  api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 1 }
  tokens     = { server = "server", agent = "agent" }
  server_group = {
    config = {
      selinux            = true
      kubelet_arg        = { "pod-max-pids" = "512" }
      kube_apiserver_arg = { "audit-log-maxage" = "30" }
      node_label         = { "example.com/role" = "server", "example.com/shared" = "group" }
      node_taint         = { "example.com/dedicated" = "control-plane:NoSchedule" }
    }
    machines = {
      "00" = { name = "00", address = "192.0.2.10", config = { node_label = { "example.com/shared" = "machine" } } }
    }
  }
  agent_groups = {
    sandboxed = {
      config = {
        selinux     = false
        kubelet_arg = { "max-pods" = "50" }
        node_taint  = { "example.com/sandbox" = "true:NoSchedule" }
      }
      machines = {
        "00" = { name = "00", address = "192.0.2.20", config = { node_taint = { "example.com/maintenance" = "true:NoExecute" } } }
      }
    }
    plain = {
      machines = { "00" = { name = "00", address = "192.0.2.30" } }
    }
  }
  kubelet_configs = [
    { content = { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", shutdownGracePeriod = "5m" } },
    { groups = ["sandboxed"], content = { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", evictionHard = { "memory.available" = "100Mi" } } },
  ]
  files = {
    "everywhere.yaml" = { content = "a: 1" }
    "server.yaml"     = { groups = ["server"], content = "b: 2" }
    "sandboxed.toml"  = { groups = ["sandboxed"], content = "c = 3" }
  }
}

run "group_and_machine_config_merge" {
  command = plan

  module {
    source = "../"
  }

  assert {
    condition = jsonencode(yamldecode(ansible_navigator_run.this.inventory).all.children.servers.hosts["server-00"].k3s_node_config) == jsonencode({
      "kube-apiserver-arg" = ["audit-log-maxage=30"]
      "kubelet-arg"        = ["pod-max-pids=512"]
      "node-external-ip"   = "192.0.2.10"
      "node-ip"            = "192.0.2.10"
      "node-label"         = ["example.com/role=server", "example.com/shared=machine"]
      "node-name"          = "server-00"
      "node-taint"         = ["example.com/dedicated=control-plane:NoSchedule"]
      "selinux"            = true
    })
    error_message = "Unexpected server K3s config."
  }

  assert {
    condition = jsonencode(yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_sandboxed.hosts["agent-sandboxed-00"].k3s_node_config) == jsonencode({
      "kubelet-arg"      = ["max-pods=50"]
      "node-external-ip" = "192.0.2.20"
      "node-ip"          = "192.0.2.20"
      "node-name"        = "agent-sandboxed-00"
      "node-taint"       = ["example.com/maintenance=true:NoExecute", "example.com/sandbox=true:NoSchedule"]
      "selinux"          = false
    })
    error_message = "Unexpected agent K3s config."
  }

  assert {
    condition = jsonencode(yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_plain.hosts["agent-plain-00"].k3s_node_config) == jsonencode({
      "node-external-ip" = "192.0.2.30"
      "node-ip"          = "192.0.2.30"
      "node-name"        = "agent-plain-00"
    })
    error_message = "A group without config must only set node identity."
  }
}

run "selectors" {
  command = plan

  module {
    source = "../"
  }

  assert {
    condition = jsonencode(yamldecode(ansible_navigator_run.this.inventory).all.children.servers.vars.k3s_kubelet_configs) == jsonencode([
      { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", shutdownGracePeriod = "5m" },
    ])
    error_message = "The server group must only get the unscoped kubelet config."
  }

  assert {
    condition = jsonencode(yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_sandboxed.vars.k3s_kubelet_configs) == jsonencode([
      { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", shutdownGracePeriod = "5m" },
      { apiVersion = "kubelet.config.k8s.io/v1beta1", evictionHard = { "memory.available" = "100Mi" }, kind = "KubeletConfiguration" },
    ])
    error_message = "The sandboxed group must get both kubelet configs, in order."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.servers.vars.k3s_files == { "everywhere.yaml" = "a: 1", "server.yaml" = "b: 2" }
    error_message = "The server group must get the unscoped file and its own."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_sandboxed.vars.k3s_files == { "everywhere.yaml" = "a: 1", "sandboxed.toml" = "c = 3" }
    error_message = "The sandboxed group must get the unscoped file and its own."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_plain.vars.k3s_files == { "everywhere.yaml" = "a: 1" }
    error_message = "A group without selected files must only get the unscoped file."
  }
}
