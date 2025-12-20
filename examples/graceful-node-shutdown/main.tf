module "k3s" {
  source  = "marshallford/k3s/ansible"
  version = "0.2.10" # x-release-please-version

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
  }

  tokens = {
    server = "some-token"
    agent  = "some-token"
  }

  server_machines = {
    a = {
      name = "a"
      ssh = {
        address = "192.168.1.100"
      }
      config = {
        cluster_init = true
      }
    }
  }

  kubelet_configs = [
    {
      apiVersion                      = "kubelet.config.k8s.io/v1beta1"
      kind                            = "KubeletConfiguration"
      shutdownGracePeriod             = "5m"
      shutdownGracePeriodCriticalPods = "1m"
    },
  ]
}
