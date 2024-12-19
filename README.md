# terraform-google-rad-security-connect

A Terraform module that establishes secure connectivity between your Google Cloud project and RAD Security's platform for cloud resource discovery and monitoring.

## Overview

This module creates and configures the necessary IAM roles and permissions to allow Rad Security to securely discover and monitor resources within your Google Cloud project. It utilizes Google Cloud's Workload Identity Federation to authenticate to your Google Cloud project without the need for creating static credentials.

## Installation

To use this module, add the following to your Terraform configuration:

```hcl
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
  access_key_id        = "YOUR_RAD_ACCESS_KEY_ID"
  secret_key           = "YOUR_RAD_SECRET_KEY"
}

provider "google" {
   // Your Google Cloud Terraform Provider configuration here
}
```

## Features

- Creates a custom IAM role with least-privilege permissions for cloud resource discovery
- Sets up Workload Identity Federation for secure cross-cloud authentication
- Configures service accounts and necessary bindings
- Registers your Google Cloud project with RAD Security's platform

## Important Notes

- This module currently supports project-level access only
- Organization-level support is not yet implemented
- Uses AWS as the identity provider for Workload Identity Federation

## How It Works

1. Creates a custom IAM role with read-only permissions required for Google Cloud resource discovery.
2. Sets up a Workload Identity Pool and Provider to authenticate RAD Security's AWS role for authentication.
3. Creates a dedicated service account in the target Google Cloud project for RAD Security.
4. Configures necessary IAM bindings between the service account and Workload Identity Pool
5. Registers your Google Cloud project with RAD Security's platform

## Configuration Options

### Required Configuration
- Configure your Google Cloud provider authentication
- Ensure the necessary Google Cloud APIs are enabled:
  - IAM API
  - Cloud Resource Manager API
  - Security Token Service API

### Optional Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| gcp_project_name | Your GCP project name | Current project |
| gcp_project_number | Your GCP project number | Current project |
| aws_account_id | RAD Security's AWS account ID | 652031173150 |
| aws_role_name | RAD Security's AWS Role Name | rad-security-connector |

## Usage Examples

### Basic Usage
```hcl
module "rad_security_connect" {
  source = "rad-security/rad-security-connect/google"
}
```

### Custom Project Configuration
```hcl
module "rad_security_connect" {
  source             = "rad-security/rad-security-connect/google"
  gcp_project_name   = "my-production-project"
  gcp_project_number = "123456789012"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.8 |
| <a name="requirement_rad-security"></a> [rad-security](#requirement\_rad-security) | >= 1.1.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_rad-security"></a> [rad-security](#provider\_rad-security) | >= 1.1.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.rad_security_identity_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.rad_aws_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_binding.rad_cloud_connect_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.rad_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_service_account.rad_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.rad_workload_identity_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [rad-security_google_cloud_register.this](https://registry.terraform.io/providers/rad-security/rad-security/latest/docs/resources/google_cloud_register) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | RAD Security's AWS account ID to authenticate with your Google Cloud project | `string` | `"955322216602"` | no |
| <a name="input_aws_role_name"></a> [aws\_role\_name](#input\_aws\_role\_name) | RAD Security's AWS Role Name to authenticate with your Google Cloud project | `string` | `"rad-security-connector"` | no |
| <a name="input_gcp_project_name"></a> [gcp\_project\_name](#input\_gcp\_project\_name) | GCP project name (optional - will use current project name if not specified) | `string` | `null` | no |
| <a name="input_gcp_project_number"></a> [gcp\_project\_number](#input\_gcp\_project\_number) | GCP project number (optional - will use current project number if not specified) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
