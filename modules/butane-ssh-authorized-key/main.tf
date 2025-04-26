terraform {
  required_version = ">= 1.12.0"
}

variable "ssh_authorized_key" {
  type        = string
  nullable    = false
  description = "SSH authorized key contents."
}

output "snippet" {
  value = templatefile("${path.module}/ssh-authorized-key.tftpl.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
  })
  description = "Butane snippet."
}
