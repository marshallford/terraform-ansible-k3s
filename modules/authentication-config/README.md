# Authentication Configuration

This submodule provides K3s configuration for API server authentication using a [structured configuration file](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-authenticator-configuration).

> [!NOTE]
> K3s does not set `--anonymous-auth=false` when this file is used ([k3s-io/k3s#12245](https://github.com/k3s-io/k3s/issues/12245)), so the `anonymous` variable (disabled by default) controls anonymous access and the audit for CIS control 1.2.1 fails.
