output "playbook_stdout" {
  value = join("\n", jsondecode(ansible_navigator_run.this.artifact_queries.stdout.results[0]))
}

output "id" {
  value = ansible_navigator_run.this.id
}

output "server" {
  value = local.server
}
