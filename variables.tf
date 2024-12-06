variable "aws_account_id" {
  description = "RAD Security's AWS account ID to authenticate with your Google Cloud project"
  default     = "652031173150"
}

variable "aws_role_name" {
  description = "RAD Security's AWS Role Name to authenticate with your Google Cloud project"
  default     = "rad-security-connector"
}

variable "gcp_project_name" {
  description = "GCP project name (optional - will use current project name if not specified)"
  type        = string
  default     = null
}

variable "gcp_project_number" {
  description = "GCP project number (optional - will use current project number if not specified)"
  type        = string
  default     = null
}
