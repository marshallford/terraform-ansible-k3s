terraform {
  required_version = ">= 1.12.0"
}

variable "wariness" {
  type        = number
  default     = 0.5
  nullable    = false
  description = "Wariness level for the Zincati update service."
}

variable "time_zone" {
  type        = string
  default     = ""
  nullable    = false
  description = "Timezone for the update windows."
}

# https://coreos.github.io/zincati/usage/updates-strategy/#periodic-strategy
variable "windows" {
  type = list(object({
    days           = list(string)
    start_time     = string
    length_minutes = number
  }))
  nullable    = false
  description = "Maintenance windows."
}

output "snippet" {
  value = templatefile("${path.module}/zincati-periodic.tftpl.yaml", {
    wariness  = var.wariness
    time_zone = var.time_zone
    windows   = var.windows
  })
  description = "Butane snippet."
}
