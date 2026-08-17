terraform {
  required_version = ">= 1.13.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
  }
}

provider "ansible" {}
