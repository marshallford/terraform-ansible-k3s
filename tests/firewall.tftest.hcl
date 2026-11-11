mock_provider "ansible" {}

variables {
  api_server      = { virtual_ip = "192.0.2.100", virtual_router_id = 1 }
  tokens          = { server = "server", agent = "agent" }
  server_machines = { firewall_rules = ["tcp dport 443 accept"], machines = { "00" = { name = "00", address = "192.0.2.10" } } }
  agent_machine_groups = {
    a = { firewall_rules = ["tcp dport 80 accept"], machines = { "00" = { name = "00", address = "192.0.2.20" } } }
  }
}

run "k3s_defaults" {
  command = plan

  module {
    source = "../"
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.vars.firewall_node_rules == ["ip saddr { 192.0.2.100, 192.0.2.10, 192.0.2.20 } accept comment \"K3s nodes\""]
    error_message = "Unexpected node firewall rules."
  }

  assert {
    condition = yamldecode(ansible_navigator_run.this.inventory).all.children.servers.vars.firewall_k3s_rules == [
      "ip saddr { 10.42.0.0/16, 10.43.0.0/16 } accept comment \"K3s pod and service networks\"",
      "meta l4proto { tcp, udp } th dport 30000-32767 accept comment \"K3s NodePorts\"",
      "tcp dport 6443 accept comment \"K3s API server\"",
    ]
    error_message = "Unexpected server K3s firewall rules."
  }

  assert {
    condition = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.vars.firewall_k3s_rules == [
      "ip saddr { 10.42.0.0/16, 10.43.0.0/16 } accept comment \"K3s pod and service networks\"",
      "meta l4proto { tcp, udp } th dport 30000-32767 accept comment \"K3s NodePorts\"",
    ]
    error_message = "Unexpected agent K3s firewall rules."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.servers.vars.firewall_rules == ["tcp dport 443 accept"]
    error_message = "Server firewall rules must be the server_machines firewall_rules."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_a.vars.firewall_rules == ["tcp dport 80 accept"]
    error_message = "Agent firewall rules must be the agent group firewall_rules."
  }
}

run "k3s_dual_stack_and_node_port_range" {
  command = plan

  module {
    source = "../"
  }

  variables {
    agent_machine_groups = {
      a = { machines = {
        "00" = { name = "00", address = "192.0.2.20" }
        "01" = { name = "01", address = "192.0.2.21", config = { node_ip = "192.0.2.21,2001:db8::21", node_external_ip = "2001:db8::121" } }
      } }
    }
    server_nodes_config = {
      cluster_cidr       = "10.42.0.0/16, 2001:db8:42::/56"
      service_cidr       = "10.43.0.0/16,2001:db8:43::/112"
      kube_apiserver_arg = { "service-node-port-range" = "20000-22767" }
    }
  }

  assert {
    condition = yamldecode(ansible_navigator_run.this.inventory).all.vars.firewall_node_rules == [
      "ip saddr { 192.0.2.100, 192.0.2.10, 192.0.2.20, 192.0.2.21 } accept comment \"K3s nodes\"",
      "ip6 saddr { 2001:db8::21, 2001:db8::121 } accept comment \"K3s nodes\"",
    ]
    error_message = "Unexpected node firewall rules."
  }

  assert {
    condition = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.vars.firewall_k3s_rules == [
      "ip saddr { 10.42.0.0/16, 10.43.0.0/16 } accept comment \"K3s pod and service networks\"",
      "ip6 saddr { 2001:db8:42::/56, 2001:db8:43::/112 } accept comment \"K3s pod and service networks\"",
      "meta l4proto { tcp, udp } th dport 20000-22767 accept comment \"K3s NodePorts\"",
    ]
    error_message = "Unexpected agent K3s firewall rules."
  }

  assert {
    condition     = yamldecode(ansible_navigator_run.this.inventory).all.children.agents.children.agents_a.vars.firewall_rules == []
    error_message = "Agent firewall rules must default to an empty list, which the playbook renders on every agent."
  }
}
