variable "streaming_connection_idle_timeout" {
  type        = string
  default     = "5m"
  nullable    = false
  description = "Maximum time a streaming connection can be idle before the connection is automatically closed."
}

variable "pod_max_pids" {
  type        = number
  default     = 512
  nullable    = false
  description = "Maximum number of processes per pod."
}

variable "audit_log" {
  type = object({
    maxage    = optional(number, 30)
    maxbackup = optional(number, 10)
    maxsize   = optional(number, 100)
  })
  default     = {}
  nullable    = false
  description = "Audit log configuration."
}

variable "terminated_pod_gc_threshold" {
  type        = number
  default     = 10
  nullable    = false
  description = "Number of terminated pods that can exist before the terminated pod garbage collector starts deleting terminated pods."
}

variable "pod_security_exemption_namespaces" {
  type        = list(string)
  default     = ["kube-system"]
  nullable    = false
  description = "Namespaces that are exempt from pod security enforcement."
}

variable "event_rate_limits" {
  type = list(object({
    type      = string
    qps       = number
    burst     = number
    cacheSize = optional(number, null)
  }))
  default = [{
    type  = "Server"
    qps   = 10000
    burst = 50000
  }]
  nullable    = false
  description = "Event rate limits."
}

variable "audit_policy_rules" {
  type = list(any)
  default = [{
    level = "Metadata"
  }]
  nullable    = false
  description = "Audit policy rules."
  validation {
    condition     = alltrue([for v in var.audit_policy_rules : can(keys(v))])
    error_message = "The audit_policy_rules variable must be a list of objects or maps."
  }
}
