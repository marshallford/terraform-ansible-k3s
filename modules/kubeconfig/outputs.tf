# output "credentials" {
#   value     = local.cluster_credentials
#   sensitive = true
#   ephemeral = true
# }

# output "yaml" {
#   value     = local.kubeconfig_yaml
#   sensitive = true
#   ephemeral = true
# }

output "persistent_credentials" {
  value       = local.persistent_cluster_credentials
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, certificate authority). Credentials are retrieved via a data source, thus are written in cleartext to state file. Protect state and plan artifacts accordingly."
}

output "persistent_yaml" {
  value       = var.persistent_outputs ? local.persistent_kubeconfig_yaml : null
  sensitive   = true
  description = "Cluster admin kubeconfig. Credentials are retrieved via a data source, thus are written in cleartext to state file. Protect state and plan artifacts accordingly."
}
