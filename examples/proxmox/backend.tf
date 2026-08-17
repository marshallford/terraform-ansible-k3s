terraform {
  required_version = ">= 1.13.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.38.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}
