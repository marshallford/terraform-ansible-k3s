terraform {
  required_version = ">= 1.15.0"
}

output "snippet" {
  type        = string
  value       = templatefile("${path.module}/count-me-opt-out.tftpl.yaml", {})
  description = "Butane snippet."
}
