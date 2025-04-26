terraform {
  required_version = ">= 1.12.0"
}

variable "wariness" {
  type        = number
  default     = 0.5
  nullable    = false
  description = "Wariness level for the Zincati update service."
}

output "snippet" {
  value = templatefile("${path.module}/zincati-immediate.tftpl.yaml", {
    wariness = var.wariness
  })
}
