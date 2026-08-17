terraform {
  required_version = ">= 1.13.0"
}

output "snippet" {
  value       = templatefile("${path.module}/count-me-opt-out.tftpl.yaml", {})
  description = "Butane snippet."
}
