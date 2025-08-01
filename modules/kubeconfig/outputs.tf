locals {
  data_facts      = try(jsondecode(data.ansible_navigator_run.this[0].artifact_queries.facts.results[0]), null)
  resource_facts  = try(jsondecode(ansible_navigator_run.this[0].artifact_queries.facts.results[0]), null)
  ephemeral_facts = try(jsondecode(ephemeral.ansible_navigator_run.this[0].artifact_queries.facts.results[0]), null)
}

output "credentials" {
  value = try(
    {
      cluster_ca_certificate = local.data_facts.cluster_ca_certificate,
      client_certificate     = local.data_facts.client_certificate,
      client_key             = local.data_facts.client_key,
    },
    {
      cluster_ca_certificate = local.resource_facts.cluster_ca_certificate,
      client_certificate     = local.resource_facts.client_certificate,
      client_key             = local.resource_facts.client_key,
    },
    {
      cluster_ca_certificate = null,
      client_certificate     = null,
      client_key             = null,
    },
  )
  sensitive   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "kubeconfig_yaml" {
  value       = try(local.data_facts.kubeconfig_yaml, local.resource_facts.kubeconfig_yaml, null)
  sensitive   = true
  description = "Cluster admin kubeconfig."
}

output "ephemeral_credentials" {
  value = try(
    {
      cluster_ca_certificate = local.ephemeral_facts.cluster_ca_certificate,
      client_certificate     = local.ephemeral_facts.client_certificate,
      client_key             = local.ephemeral_facts.client_key,
    },
    {
      cluster_ca_certificate = null,
      client_certificate     = null,
      client_key             = null,
    },
  )
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin credentials (client certificate, client key, cluster ca certificate)."
}

output "ephemeral_kubeconfig_yaml" {
  value       = try(local.ephemeral_facts.kubeconfig_yaml, null)
  sensitive   = true
  ephemeral   = true
  description = "Cluster admin kubeconfig."
}
