# Cilium CNI Example

This example demonstrates how to deploy a k3s cluster with Cilium as the container network interface (CNI). The default CNI Flannel and the embedded network policy controller must be disabled via `server_nodes_config` in order to use Cilium. This example uses the Helm provider to install Cilium via the official Helm chart. More details about Cilium on k3s can be found in the [Cilium documentation](https://docs.cilium.io/en/stable/installation/k3s/).
