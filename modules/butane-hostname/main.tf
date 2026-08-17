terraform {
  required_version = ">= 1.13.0"
}

variable "hostname" {
  type        = string
  nullable    = false
  description = "Machine hostname."
}

output "snippet" {
  value = templatefile("${path.module}/hostname.tftpl.yaml", {
    hostname = var.hostname
  })
  description = "Butane snippet."
}
