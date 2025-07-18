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

output "credentials" {
  value       = module.kubeconfig.credentials
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "kubeconfig_yaml" {
  value       = module.kubeconfig.kubeconfig_yaml
  sensitive   = true
  description = "Cluster admin kubeconfig."
}

output "ephemeral_credentials" {
  value       = module.kubeconfig.ephemeral_credentials
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "ephemeral_kubeconfig_yaml" {
  value       = module.kubeconfig.ephemeral_kubeconfig_yaml
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin kubeconfig."
}
