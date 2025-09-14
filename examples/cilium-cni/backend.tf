terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.33.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "ansible" {}
