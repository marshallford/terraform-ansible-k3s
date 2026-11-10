output "machine_ssh_private_key" {
  value     = tls_private_key.machine.private_key_openssh
  sensitive = true
}

output "playbook_summary" {
  value = module.k3s.playbook_summary
}

output "kubeconfig_yaml" {
  value     = module.k3s.kubeconfig_yaml
  sensitive = true
}
