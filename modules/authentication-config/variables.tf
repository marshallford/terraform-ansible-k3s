variable "anonymous" {
  type = any
  default = {
    enabled = false
  }
  nullable = false
  validation {
    condition     = can(keys(var.anonymous))
    error_message = "The anonymous variable must be an object or map."
  }
  description = "Anonymous configuration."
}

variable "jwt" {
  type     = any
  default  = []
  nullable = false
  validation {
    condition     = can(slice(var.jwt, 0, 0)) && alltrue([for v in var.jwt : can(keys(v))])
    error_message = "The jwt variable must be a list of objects or maps."
  }
  description = "JWT configuration."
}
