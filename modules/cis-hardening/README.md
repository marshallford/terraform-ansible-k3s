# CIS Hardening

This submodule provides k3s configuration based on the [CIS hardening guide](https://docs.k3s.io/security/hardening-guide).

## Example

```hcl
module "k3s_cis_hardening" {
  source = "marshallford/k3s/ansible//modules/cis-hardening"
}

module "k3s" {
  source = "marshallford/k3s/ansible"

  # ...

  all_nodes_config    = module.k3s_cis_hardening.all_nodes_config
  server_nodes_config = module.k3s_cis_hardening.server_nodes_config
  files               = module.k3s_cis_hardening.files
}
```

## Out of scope

This module does not address the following:

1. Network policies
2. Controls: 1.1.20, 1.2.11, 1.2.21, 5.x
