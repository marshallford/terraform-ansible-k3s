terraform {
  required_version = ">= 1.12.0"
}

variable "timezone" {
  type        = string
  nullable    = false
  description = "Machine timezone."
}

output "snippet" {
  value = templatefile("${path.module}/timezone.tftpl.yaml", {
    timezone = var.timezone
  })
}
