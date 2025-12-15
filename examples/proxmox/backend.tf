terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.35.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
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
