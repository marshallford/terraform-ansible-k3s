terraform {
  required_version = ">= 1.12.0"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.33.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "ansible" {}
