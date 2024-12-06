terraform {
  required_version = ">= 1.0.8"

  required_providers {
    rad-security = {
      source  = "rad-security/rad-security"
      version = ">= 1.1.6"
    }
  }
}
