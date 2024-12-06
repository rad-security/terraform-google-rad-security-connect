resource "google_iam_workload_identity_pool" "rad_security_identity_pool" {
  workload_identity_pool_id = "rad-security-identity-pool"
  display_name              = "RAD Security Identity Pool"
  description               = "Identity pool for RAD Security"
}

resource "google_iam_workload_identity_pool_provider" "rad_aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.rad_security_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "rad-security-aws-provider"
  display_name                       = "RAD Security AWS Provider"

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
  }

  attribute_condition = "assertion.account == '${var.aws_account_id}' && assertion.arn.contains('${var.aws_role_name}')"

  aws {
    account_id = var.aws_account_id
  }
}

resource "google_service_account" "rad_cloud_connect" {
  account_id   = "rad-security-cloud-connect"
  display_name = "RAD Security Cloud Connect"
}

resource "google_service_account_iam_binding" "rad_workload_identity_user" {
  service_account_id = google_service_account.rad_cloud_connect.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.rad_security_identity_pool.name}/attribute.aws_account/${var.aws_account_id}"
  ]
}

resource "google_project_iam_custom_role" "rad_cloud_connect" {
  project     = local.project_name
  role_id     = "rad_security_cloud_connect_role"
  title       = "RAD Security Cloud Connect Role"
  description = "RAD Security's Google Cloud Role to retrieve Google Cloud resources"
  permissions = [
    "container.clusters.get",
    "container.clusters.list"
  ]
}

resource "google_project_iam_binding" "rad_cloud_connect_access" {
  project = local.project_name
  role    = google_project_iam_custom_role.rad_cloud_connect.id

  members = [
    "serviceAccount:${google_service_account.rad_cloud_connect.email}"
  ]
}

resource "rad-security_google_cloud_register" "this" {
  depends_on = [
    google_project_iam_binding.rad_cloud_connect_access
  ]

  google_cloud_service_account_email = google_service_account.rad_cloud_connect.email
  google_cloud_pool_provider_name    = google_iam_workload_identity_pool_provider.rad_aws_provider.name
  google_cloud_project_number        = local.project_number
}
