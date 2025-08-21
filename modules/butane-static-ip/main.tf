terraform {
  required_version = ">= 1.12.0"
}

variable "interface" {
  type        = string
  nullable    = false
  description = "Network interface to configure with a static IP address."
}

variable "ip" {
  type        = string
  nullable    = false
  description = "Static IP address to assign to the interface."
}

variable "prefix" {
  type        = number
  default     = 24
  nullable    = false
  description = "Subnet prefix for the static IP address."
}

variable "gateway" {
  type        = string
  default     = null
  nullable    = true
  description = "Gateway IP address for the network."
}

variable "nameservers" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "DNS nameservers."
}

variable "search_domains" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "DNS search domains."
}

variable "static_routes" {
  type = list(object({
    address = string
    prefix  = optional(number, 24)
    gateway = optional(string)
    metric  = optional(number)
  }))
  default     = []
  nullable    = false
  description = "Static routes."
}

output "snippet" {
  value = templatefile("${path.module}/static-ip.tftpl.yaml", {
    interface      = var.interface,
    ip             = var.ip,
    prefix         = var.prefix,
    gateway        = var.gateway,
    nameservers    = var.nameservers,
    search_domains = var.search_domains,
    static_routes  = var.static_routes,
  })
  description = "Butane snippet."
}
