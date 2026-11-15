module "k3s" {
  source = "../../"

  api_server = {
    virtual_ip        = "192.168.1.99"
    virtual_router_id = 1
  }

  tokens = {
    server = "some-token"
    agent  = "some-token"
  }

  server_group = {
    machines = {
      a = {
        name    = "a"
        address = "192.168.1.100"
      }
    }
  }

  kubelet_configs = [
    {
      content = {
        apiVersion                      = "kubelet.config.k8s.io/v1beta1"
        kind                            = "KubeletConfiguration"
        shutdownGracePeriod             = "5m"
        shutdownGracePeriodCriticalPods = "1m"
      }
    },
  ]
}
