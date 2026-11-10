mock_provider "ansible" {}

variables {
  api_server      = { virtual_ip = "192.0.2.100", virtual_router_id = 1 }
  tokens          = { server = "server", agent = "agent" }
  server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10" } } }
}

run "valid_boundary_values" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 255 }
    tokens     = { server = "s", agent = "a" }
    server_machines = { ssh = { port = 65535 }, machines = {
      "00" = { name = "00", address = "192.0.2.10", config = { node_name = format("%063d", 0) } }
      "01" = { name = "01", address = "192.0.2.11" }
      "02" = { name = "02", address = "server-02.example.com", config = { node_ip = "192.0.2.12", node_external_ip = "198.51.100.12" } }
    } }
    agent_machine_groups = {
      a = { ssh = { port = 1 }, machines = {
        "00" = { name = "00", address = "192.0.2.20", config = { node_name = "agent-a-00" } }
        "01" = { name = "01", address = "agent-a-01.example.com", config = { node_ip = "192.0.2.22,2001:db8::22", node_external_ip = "2001:db8::122" } }
      } }
      b = { machines = { "00" = { name = format("%055d", 0), address = "192.0.2.21" } } }
    }
    k3s_version         = "1.38.0-rc1+k3s1"
    k3s_selinux_version = "1.6.1"
    kubelet_configs = [
      { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", shutdownGracePeriod = "5m" },
      { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration", evictionHard = { "memory.available" = "100Mi" } },
    ]
    registries_config     = { mirrors = {} }
    drain_options         = { eviction_timeout = "1h30m", deletion_timeout = "30s" }
    kubeconfig_block_type = "data"
  }
}

run "api_server_virtual_router_id_too_low" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 0 }
  }

  expect_failures = [var.api_server]
}

run "api_server_virtual_router_id_too_high" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 256 }
  }

  expect_failures = [var.api_server]
}

run "server_machines_empty" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = {} }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_duplicate_names" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = {
      "00" = { name = "00", address = "192.0.2.10", config = { node_name = "server-a" } }
      "01" = { name = "00", address = "192.0.2.11", config = { node_name = "server-b" } }
    } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_node_name_invalid_characters" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10", config = { node_name = "Server_00" } } } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_node_name_too_long" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10", config = { node_name = format("%064d", 0) } } } }
  }

  expect_failures = [var.server_machines]
}

run "agent_machine_groups_duplicate_names" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = {
      "00" = { name = "00", address = "192.0.2.20", config = { node_name = "agent-a" } }
      "01" = { name = "00", address = "192.0.2.21", config = { node_name = "agent-b" } }
    } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_node_name_invalid_characters" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_name = "-agent" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_node_name_too_long" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_name = format("%064d", 0) } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "k3s_version_v_prefix" {
  command = plan

  module {
    source = "../"
  }

  variables {
    k3s_version = "v1.37.2+k3s1"
  }

  expect_failures = [var.k3s_version]
}

run "k3s_selinux_version_v_prefix" {
  command = plan

  module {
    source = "../"
  }

  variables {
    k3s_selinux_version = "v1.6.1"
  }

  expect_failures = [var.k3s_selinux_version]
}

run "kubelet_configs_not_objects" {
  command = plan

  module {
    source = "../"
  }

  variables {
    kubelet_configs = ["shutdownGracePeriod: 5m"]
  }

  expect_failures = [var.kubelet_configs]
}

run "kubelet_configs_missing_api_version" {
  command = plan

  module {
    source = "../"
  }

  variables {
    kubelet_configs = [{ kind = "KubeletConfiguration" }]
  }

  expect_failures = [var.kubelet_configs]
}

run "kubelet_configs_wrong_kind" {
  command = plan

  module {
    source = "../"
  }

  variables {
    kubelet_configs = [{ apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeProxyConfiguration" }]
  }

  expect_failures = [var.kubelet_configs]
}

run "registries_config_not_object" {
  command = plan

  module {
    source = "../"
  }

  variables {
    registries_config = "mirrors: {}"
  }

  expect_failures = [var.registries_config]
}

run "drain_options_eviction_timeout_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    drain_options = { eviction_timeout = "30 minutes" }
  }

  expect_failures = [var.drain_options]
}

run "drain_options_deletion_timeout_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    drain_options = { deletion_timeout = "ten minutes" }
  }

  expect_failures = [var.drain_options]
}

run "kubeconfig_block_type_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    kubeconfig_block_type = "local"
  }

  expect_failures = [var.kubeconfig_block_type]
}

run "api_server_virtual_ip_hostname" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "k3s.example.com", virtual_router_id = 1 }
  }

  expect_failures = [var.api_server]
}

run "api_server_virtual_ip_ipv6" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "2001:db8::100", virtual_router_id = 1 }
  }

  expect_failures = [var.api_server]
}

run "tokens_server_empty" {
  command = plan

  module {
    source = "../"
  }

  variables {
    tokens = { server = "", agent = "agent" }
  }

  expect_failures = [var.tokens]
}

run "tokens_agent_empty" {
  command = plan

  module {
    source = "../"
  }

  variables {
    tokens = { server = "server", agent = "" }
  }

  expect_failures = [var.tokens]
}

run "server_machines_default_node_name_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "Server_00", address = "192.0.2.10" } } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_node_names_not_unique" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = {
      "00" = { name = "00", address = "192.0.2.10", config = { node_name = "server-01" } }
      "01" = { name = "01", address = "192.0.2.11" }
    } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_ssh_port_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { ssh = { port = 0 }, machines = { "00" = { name = "00", address = "192.0.2.10" } } }
  }

  expect_failures = [var.server_machines]
}

run "agent_machine_groups_default_node_name_too_long" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { b = { machines = { "00" = { name = format("%056d", 0), address = "192.0.2.20" } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_node_name_overlaps_server" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_name = "server-00" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_ssh_port_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { ssh = { port = 65536 }, machines = { "00" = { name = "00", address = "192.0.2.20" } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "k3s_version_not_semver" {
  command = plan

  module {
    source = "../"
  }

  variables {
    k3s_version = "1.37.2 k3s1"
  }

  expect_failures = [var.k3s_version]
}

run "k3s_selinux_version_not_semver" {
  command = plan

  module {
    source = "../"
  }

  variables {
    k3s_selinux_version = "1.6"
  }

  expect_failures = [var.k3s_selinux_version]
}

run "kubelet_configs_not_list" {
  command = plan

  module {
    source = "../"
  }

  variables {
    kubelet_configs = { apiVersion = "kubelet.config.k8s.io/v1beta1", kind = "KubeletConfiguration" }
  }

  expect_failures = [var.kubelet_configs]
}

run "api_server_virtual_router_id_not_whole" {
  command = plan

  module {
    source = "../"
  }

  variables {
    api_server = { virtual_ip = "192.0.2.100", virtual_router_id = 1.5 }
  }

  expect_failures = [var.api_server]
}

run "server_machines_address_hostname" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "server-00.example.com" } } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_node_ip_ipv6" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10", config = { node_ip = "2001:db8::10" } } } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_external_ip_hostname" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "server-00.example.com", config = { node_ip = "192.0.2.10" } } } }
  }

  expect_failures = [var.server_machines]
}

run "server_machines_ssh_port_not_whole" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { ssh = { port = 22.5 }, machines = { "00" = { name = "00", address = "192.0.2.10" } } }
  }

  expect_failures = [var.server_machines]
}

run "agent_machine_groups_address_hostname" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "agent-a-00.example.com" } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_external_ip_invalid" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_external_ip = "192.0.2.300" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_ssh_port_not_whole" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { ssh = { port = 22.5 }, machines = { "00" = { name = "00", address = "192.0.2.20" } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_node_ip_hostname" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "agent-a-00.example.com", config = { node_external_ip = "198.51.100.20" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "server_machines_external_ip_list" {
  command = plan

  module {
    source = "../"
  }

  variables {
    server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10", config = { node_external_ip = "198.51.100.10,2001:db8::10" } } } }
  }

  expect_failures = [var.server_machines]
}

run "agent_machine_groups_node_ip_same_family_pair" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_ip = "192.0.2.20,192.0.2.21" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}

run "agent_machine_groups_node_ip_more_than_two" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = { a = { machines = { "00" = { name = "00", address = "192.0.2.20", config = { node_ip = "192.0.2.20,2001:db8::20,2001:db8::21" } } } } }
  }

  expect_failures = [var.agent_machine_groups]
}
