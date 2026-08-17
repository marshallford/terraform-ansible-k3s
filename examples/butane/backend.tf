terraform {
  required_version = ">= 1.13.0"
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}

provider "ct" {}
