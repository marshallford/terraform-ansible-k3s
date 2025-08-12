# Graceful Node Shutdown Example

This example demonstrates how to configure k3s cluster nodes to gracefully [shutdown](https://kubernetes.io/docs/concepts/cluster-administration/node-shutdown/). To enable Kubelet's graceful shutdown mechanism, the options `shutdownGracePeriod` and `shutdownGracePeriodCriticalPods` are configured via a [`KubeletConfiguration`](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/) file.
