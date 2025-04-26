terraform {
  required_version = ">= 1.12.0"
}

output "snippet" {
  value = templatefile("${path.module}/python.tftpl.yaml", {})
}
