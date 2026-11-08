terraform {
  required_version = ">= 1.15.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.39.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "ansible" {}
