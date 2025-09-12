terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.32.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
