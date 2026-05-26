terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.36.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
}

provider "ansible" {}
