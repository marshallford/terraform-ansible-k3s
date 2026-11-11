mock_provider "ansible" {}

run "authentication_config_valid_jwt_shapes" {
  command = plan

  module {
    source = "../modules/authentication-config"
  }

  variables {
    jwt = [
      { issuer = { url = "https://a.example.com", audiences = ["a"] } },
      { issuer = { url = "https://b.example.com", audiences = ["b"] }, claimMappings = { username = { claim = "sub", prefix = "" } } },
    ]
  }
}

run "authentication_config_anonymous_not_object" {
  command = plan

  module {
    source = "../modules/authentication-config"
  }

  variables {
    anonymous = "enabled"
  }

  expect_failures = [var.anonymous]
}

run "authentication_config_jwt_not_list" {
  command = plan

  module {
    source = "../modules/authentication-config"
  }

  variables {
    jwt = { issuer = { url = "https://a.example.com" } }
  }

  expect_failures = [var.jwt]
}

run "authentication_config_jwt_not_objects" {
  command = plan

  module {
    source = "../modules/authentication-config"
  }

  variables {
    jwt = ["issuer: https://example.com"]
  }

  expect_failures = [var.jwt]
}

run "butane_zincati_periodic_windows_empty" {
  command = plan

  module {
    source = "../modules/butane-zincati-periodic"
  }

  variables {
    windows = []
  }

  expect_failures = [var.windows]
}

run "cis_hardening_audit_policy_rules_not_list" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }

  variables {
    audit_policy_rules = { level = "Metadata" }
  }

  expect_failures = [var.audit_policy_rules]
}

run "cis_hardening_audit_policy_rules_not_objects" {
  command = plan

  module {
    source = "../modules/cis-hardening"
  }

  variables {
    audit_policy_rules = ["level: Metadata"]
  }

  expect_failures = [var.audit_policy_rules]
}

run "kubeconfig_ssh_port_invalid" {
  command = plan

  module {
    source = "../modules/kubeconfig"
  }

  variables {
    server_machine = { address = "192.0.2.10", ssh = { port = 70000 } }
    server         = "https://192.0.2.100:6443"
  }

  expect_failures = [var.server_machine]
}

run "kubeconfig_ssh_port_not_whole" {
  command = plan

  module {
    source = "../modules/kubeconfig"
  }

  variables {
    server_machine = { address = "192.0.2.10", ssh = { port = 22.5 } }
    server         = "https://192.0.2.100:6443"
  }

  expect_failures = [var.server_machine]
}

run "kubeconfig_block_type_invalid" {
  command = plan

  module {
    source = "../modules/kubeconfig"
  }

  variables {
    server_machine = { address = "192.0.2.10" }
    server         = "https://192.0.2.100:6443"
    block_type     = "local"
  }

  expect_failures = [var.block_type]
}
