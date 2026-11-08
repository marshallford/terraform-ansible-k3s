terraform {
  required_version = ">= 1.15.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.39.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.120.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.5.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.4.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
