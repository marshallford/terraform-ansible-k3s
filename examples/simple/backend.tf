terraform {
  required_version = ">= 1.13.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.38.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
  }
}

provider "ansible" {}
