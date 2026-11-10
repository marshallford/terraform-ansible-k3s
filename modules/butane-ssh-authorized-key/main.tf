terraform {
  required_version = ">= 1.15.0"
}

variable "ssh_authorized_key" {
  type        = string
  nullable    = false
  description = "SSH authorized key contents."
}

output "snippet" {
  type = string
  value = templatefile("${path.module}/ssh-authorized-key.tftpl.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
  })
  description = "Butane snippet."
}
