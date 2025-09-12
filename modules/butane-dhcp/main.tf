terraform {
  required_version = ">= 1.12.0"
}

variable "interface" {
  type        = string
  nullable    = false
  description = "Network interface to configure with DHCP."
}

output "snippet" {
  value = templatefile("${path.module}/dhcp.tftpl.yaml", {
    interface      = var.interface,
  })
  description = "Butane snippet."
}
