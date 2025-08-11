variable "private_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "SSH private key."
}
