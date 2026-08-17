terraform {
  required_version = ">= 1.13.0"
}

output "snippet" {
  value       = templatefile("${path.module}/zincati-disable.tftpl.yaml", {})
  description = "Butane snippet."
}
