output "credentials" {
  value       = module.k3s_kubeconfig.credentials
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "kubeconfig_yaml" {
  value       = module.k3s_kubeconfig.kubeconfig_yaml
  sensitive   = true
  description = "Cluster admin kubeconfig."
}
