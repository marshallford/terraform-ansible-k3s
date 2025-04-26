output "playbook_stdout" {
  value       = join("\n", jsondecode(ansible_navigator_run.this.artifact_queries.stdout.results[0]))
  description = "Stdout of Ansible playbook run."
}

output "id" {
  value       = ansible_navigator_run.this.id
  description = "ID of the Ansible playbook run."
}

output "server" {
  value       = local.server
  description = "Kubernetes API server host."
}

# output "cluster_credentials" {
#   value = module.kubeconfig.credentials
#   sensitive = true
#   ephemeral = true
# }

# output "kubeconfig_yaml" {
#   value = module.kubeconfig.yaml
#   sensitive = true
#   ephemeral = true
# }

output "persistent_cluster_credentials" {
  value       = module.kubeconfig.persistent_credentials
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, certificate authority). Credentials are retrieved via a data source, thus are written in cleartext to state file. Protect state and plan artifacts accordingly."
}

output "persistent_kubeconfig_yaml" {
  value       = module.kubeconfig.persistent_yaml
  sensitive   = true
  description = "Cluster admin kubeconfig. Credentials are retrieved via a data source, thus are written in cleartext to state file. Protect state and plan artifacts accordingly."
}
