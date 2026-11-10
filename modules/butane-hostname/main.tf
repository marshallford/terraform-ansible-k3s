terraform {
  required_version = ">= 1.15.0"
}

variable "hostname" {
  type        = string
  nullable    = false
  description = "Machine hostname."
}

output "snippet" {
  type = string
  value = templatefile("${path.module}/hostname.tftpl.yaml", {
    hostname = var.hostname
  })
  description = "Butane snippet."
}
