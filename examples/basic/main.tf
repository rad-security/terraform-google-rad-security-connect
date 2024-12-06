terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    rad-security = {
      source  = "rad-security/rad-security"
      version = ">= 1.1.6"
    }
  }
}

provider "rad-security" {
  access_key_id = var.rad_access_key_id
  secret_key    = var.rad_secret_key
}

provider "google" {
  // Your Google Cloud Terraform Provider configuration here
}


module "rad-security-connect" {
  # https://registry.terraform.io/modules/rad-security/rad-security-connect/google/latest
  source  = "rad-security/rad-security-connect/google"
  version = "<version>"

}
