# CIS Hardening

This submodule provides K3s configuration based on the [CIS hardening guide](https://docs.k3s.io/security/hardening-guide) and the [CIS 2.0 self-assessment](https://docs.k3s.io/security/self-assessment-2.0) (K3s v1.34-v1.37).

## Example

See [examples/cis-hardening](/examples/cis-hardening).

## Controls

### Configured by this module

Besides the hardening guide's configuration, this module addresses the following controls, which K3s marks as manual (`WARN`) in the self-assessment:

| Control      | Setting                                   | Variable                                          |
| ------------ | ----------------------------------------- | ------------------------------------------------- |
| 1.2.3        | `DenyServiceExternalIPs` admission plugin | `deny_service_external_ips`                       |
| 1.2.9        | `EventRateLimit` admission plugin         | always on, limits in `event_rate_limits`          |
| 4.2.12       | Kubelet `tls-cipher-suites`               | always on                                         |
| 4.2.13       | Kubelet `pod-max-pids`                    | `pod_max_pids`                                    |
| 4.2.14       | Kubelet `seccomp-default`                 | `seccomp_default`                                 |
| 5.2.1-5.2.12 | `restricted` Pod Security Standard        | exemptions in `pod_security_exemption_namespaces` |

### Met without configuration

1. Kernel parameters required by `protect-kernel-defaults`: always set by the playbook
2. Audit log directory permissions: K3s creates `/var/lib/rancher/k3s/server` with mode 700
3. Control 1.2.20 (`--request-timeout`): the default of 60 seconds, which CIS recommends changing only if needed

### Known audit failures

1. Control 1.2.1 (`--anonymous-auth`): K3s doesn't set the flag when the [authentication-config](/modules/authentication-config) submodule is used ([k3s-io/k3s#12245](https://github.com/k3s-io/k3s/issues/12245)); that submodule's `anonymous` variable governs anonymous access instead

### Out of scope

This module does not address the following:

1. Control 1.2.11 (`AlwaysPullImages`): every container start must reach the image registry, even for images preloaded from the K3s airgap images archive
2. Controls 5.1 (RBAC and service accounts), 5.3.2 (network policies), 5.4 (secrets management), 5.5 (image provenance) and 5.6 (general policies)
