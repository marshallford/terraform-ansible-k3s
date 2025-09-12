provider "ansible" {}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

provider "kubernetes" {
  host                   = module.k3s.server
  cluster_ca_certificate = module.k3s.credentials.cluster_ca_certificate
  client_certificate     = module.k3s.credentials.client_certificate
  client_key             = module.k3s.credentials.client_key
}

provider "ct" {}

provider "tls" {}

provider "time" {}

provider "random" {}
