terraform {
  required_version = ">= 1.12.0"
}

variable "test_dns_host" {
  type        = string
  default     = "mirrors.fedoraproject.org"
  nullable    = false
  description = "DNS host for connectivity test before rpm-ostree install."
}

output "snippet" {
  value       = templatefile("${path.module}/qemu-ga.tftpl.yaml", {
    test_dns_host = var.test_dns_host
  })
  description = "Butane snippet."
}
