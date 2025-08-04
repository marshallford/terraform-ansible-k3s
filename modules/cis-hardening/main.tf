terraform {
  required_version = ">= 1.12.0"
}

output "all_nodes_config" {
  value = {
    protect_kernel_defaults = true
    selinux                 = true
    kubelet_arg = {
      "streaming-connection-idle-timeout" = var.streaming_connection_idle_timeout
      "tls-cipher-suites"                 = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
      "pod-max-pids"                      = var.pod_max_pids
    }
  }
}

output "server_nodes_config" {
  value = {
    secrets_encryption = true
    kube_apiserver_arg = {
      "enable-admission-plugins"      = "NodeRestriction,EventRateLimit"
      "admission-control-config-file" = "K3S_FILES_DIR/admission-control.yaml"
      "audit-log-path"                = "/var/lib/rancher/k3s/server/logs/audit.log"
      "audit-policy-file"             = "K3S_FILES_DIR/audit.yaml"
      "audit-log-maxage"              = var.audit_log.maxage
      "audit-log-maxbackup"           = var.audit_log.maxbackup
      "audit-log-maxsize"             = var.audit_log.maxsize
    }
    kube_controller_manager_arg = {
      "terminated-pod-gc-threshold" = var.terminated_pod_gc_threshold
    }
  }
}

output "files" {
  value = {
    "admission-control.yaml" = yamlencode({
      apiVersion = "apiserver.config.k8s.io/v1"
      kind       = "AdmissionConfiguration"
      plugins = [
        {
          name = "PodSecurity"
          configuration = {
            apiVersion = "pod-security.admission.config.k8s.io/v1beta1"
            kind       = "PodSecurityConfiguration"
            defaults = {
              enforce         = "restricted"
              enforce-version = "latest"
              audit           = "restricted"
              audit-version   = "latest"
              warn            = "restricted"
              warn-version    = "latest"
            }
            exemptions = {
              usernames      = []
              runtimeClasses = []
              namespaces     = var.pod_security_exemption_namespaces
            }
          }
        },
        {
          name = "EventRateLimit"
          configuration = {
            apiVersion = "eventratelimit.admission.k8s.io/v1alpha1"
            kind       = "Configuration"
            limits     = var.event_rate_limits
          }
        }
      ]
    })
    "audit.yaml" = yamlencode({
      apiVersion = "audit.k8s.io/v1"
      kind       = "Policy"
      rules      = var.audit_policy_rules
    })
  }
}
