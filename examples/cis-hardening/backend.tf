terraform {
  required_version = ">= 1.12.2"
  required_providers {
    ansible = {
      source  = "marshallford/ansible"
      version = "0.32.0"
    }
  }
}

provider "ansible" {}
