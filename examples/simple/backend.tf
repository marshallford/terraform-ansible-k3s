terraform {
  required_version = ">= 1.15.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.39.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.5.0"
    }
  }
}

provider "ansible" {}
