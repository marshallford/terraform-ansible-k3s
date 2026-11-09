mock_provider "ansible" {}

variables {
  api_server      = { virtual_ip = "192.0.2.100", virtual_router_id = 1 }
  tokens          = { server = "server", agent = "agent" }
  server_machines = { machines = { "00" = { name = "00", address = "192.0.2.10" } } }
}

run "role_defaults_match_variable_defaults" {
  command = plan

  module {
    source = "../"
  }

  assert {
    condition     = jsonencode(var.k3s_version) == jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_version)
    error_message = "var.k3s_version (${jsonencode(var.k3s_version)}) differs from the k3s role default k3s_version (${jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_version)})."
  }

  assert {
    condition     = jsonencode(var.k3s_selinux_version) == jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_selinux_version)
    error_message = "var.k3s_selinux_version (${jsonencode(var.k3s_selinux_version)}) differs from the k3s role default k3s_selinux_version (${jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_selinux_version)})."
  }

  assert {
    condition     = jsonencode(var.drain_options) == jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_drain_options)
    error_message = "var.drain_options (${jsonencode(var.drain_options)}) differs from the k3s role default k3s_drain_options (${jsonencode(yamldecode(file("../ansible/roles/k3s/defaults/main.yaml")).k3s_drain_options)})."
  }

  assert {
    condition     = jsonencode(var.haproxy_container_image) == jsonencode(yamldecode(file("../ansible/roles/haproxy/defaults/main.yaml")).haproxy_container_image)
    error_message = "var.haproxy_container_image (${jsonencode(var.haproxy_container_image)}) differs from the haproxy role default haproxy_container_image (${jsonencode(yamldecode(file("../ansible/roles/haproxy/defaults/main.yaml")).haproxy_container_image)})."
  }

  assert {
    condition     = jsonencode(var.haproxy_container_image_tag) == jsonencode(yamldecode(file("../ansible/roles/haproxy/defaults/main.yaml")).haproxy_container_image_tag)
    error_message = "var.haproxy_container_image_tag (${jsonencode(var.haproxy_container_image_tag)}) differs from the haproxy role default haproxy_container_image_tag (${jsonencode(yamldecode(file("../ansible/roles/haproxy/defaults/main.yaml")).haproxy_container_image_tag)})."
  }

  assert {
    condition     = jsonencode(var.keepalived_container_image) == jsonencode(yamldecode(file("../ansible/roles/keepalived/defaults/main.yaml")).keepalived_container_image)
    error_message = "var.keepalived_container_image (${jsonencode(var.keepalived_container_image)}) differs from the keepalived role default keepalived_container_image (${jsonencode(yamldecode(file("../ansible/roles/keepalived/defaults/main.yaml")).keepalived_container_image)})."
  }

  assert {
    condition     = jsonencode(var.keepalived_container_image_tag) == jsonencode(yamldecode(file("../ansible/roles/keepalived/defaults/main.yaml")).keepalived_container_image_tag)
    error_message = "var.keepalived_container_image_tag (${jsonencode(var.keepalived_container_image_tag)}) differs from the keepalived role default keepalived_container_image_tag (${jsonencode(yamldecode(file("../ansible/roles/keepalived/defaults/main.yaml")).keepalived_container_image_tag)})."
  }

  assert {
    condition     = jsonencode(var.system_upgrade_trigger) == jsonencode(yamldecode(file("../ansible/roles/system_upgrade/defaults/main.yaml")).system_upgrade_trigger)
    error_message = "var.system_upgrade_trigger (${jsonencode(var.system_upgrade_trigger)}) differs from the system_upgrade role default system_upgrade_trigger (${jsonencode(yamldecode(file("../ansible/roles/system_upgrade/defaults/main.yaml")).system_upgrade_trigger)})."
  }
}
