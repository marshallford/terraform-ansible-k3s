output "playbook_stdout" {
  type        = string
  value       = var.playbook_stdout_enabled ? join("\n", jsondecode(ansible_navigator_run.this.artifact_queries["stdout"].results[0])) : null
  description = "Stdout of Ansible playbook run. Requires playbook_stdout_enabled, otherwise null."
}

output "playbook_summary" {
  type = object({
    changed_per_host = map(number)
    changed_tasks    = map(number)
    slowest_tasks    = list(object({ task = string, host_seconds = number }))
  })
  value       = jsondecode(ansible_navigator_run.this.artifact_queries.summary.results[0])
  description = "Summary of Ansible playbook run: changed task count per host, change count per changed task, and the ten slowest tasks by host_seconds (task duration summed across all hosts and plays, not wall-clock time)."
}

output "id" {
  type        = string
  value       = ansible_navigator_run.this.id
  description = "ID of the Ansible playbook run."
}

output "server" {
  type        = string
  value       = local.server
  description = "Kubernetes API server URL."
}

output "credentials" {
  type = object({
    cluster_ca_certificate = string
    client_certificate     = string
    client_key             = string
  })
  value       = module.kubeconfig.credentials
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "kubeconfig_yaml" {
  type        = string
  value       = module.kubeconfig.kubeconfig_yaml
  sensitive   = true
  description = "Cluster admin kubeconfig."
}

output "ephemeral_credentials" {
  type = object({
    cluster_ca_certificate = string
    client_certificate     = string
    client_key             = string
  })
  value       = module.kubeconfig.ephemeral_credentials
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "ephemeral_kubeconfig_yaml" {
  type        = string
  value       = module.kubeconfig.ephemeral_kubeconfig_yaml
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin kubeconfig."
}
