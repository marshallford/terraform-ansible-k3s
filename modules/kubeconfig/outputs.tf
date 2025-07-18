output "credentials" {
  value       = var.block_type == "data" ? local.data_credentials : (var.block_type == "resource" ? local.resource_credentials : null)
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "kubeconfig_yaml" {
  value       = var.block_type == "data" ? local.data_kubeconfig_yaml : (var.block_type == "resource" ? local.resource_kubeconfig_yaml : null)
  sensitive   = true
  description = "Cluster admin kubeconfig."
}

output "ephemeral_credentials" {
  value       = var.block_type == "ephemeral" ? local.ephemeral_credentials : null
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "ephemeral_kubeconfig_yaml" {
  value       = var.block_type == "ephemeral" ? local.ephemeral_kubeconfig_yaml : null
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin kubeconfig."
}
