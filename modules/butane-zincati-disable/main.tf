terraform {
  required_version = ">= 1.15.0"
}

output "snippet" {
  type        = string
  value       = templatefile("${path.module}/zincati-disable.tftpl.yaml", {})
  description = "Butane snippet."
}
