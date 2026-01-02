variable "anonymous" {
  type = any
  default = {
    enabled = false
  }
  nullable    = false
  description = "Anonymous configuration."

  validation {
    condition     = can(keys(var.anonymous))
    error_message = "The anonymous variable must be an object or map."
  }
}

variable "jwt" {
  type        = list(any)
  default     = []
  nullable    = false
  description = "JWT configuration."
  validation {
    condition     = alltrue([for v in var.jwt : can(keys(v))])
    error_message = "The jwt variable must be a list of objects or maps."
  }
}
