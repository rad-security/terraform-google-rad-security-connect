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
    "container.clusters.list",
    "bigquery.datasets.listEffectiveTags",
    "bigquery.datasets.listSharedDatasetUsage",
    "bigquery.datasets.listTagBindings",
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.tables.list",
    "bigquery.tables.listEffectiveTags",
    "bigquery.tables.listTagBindings",
    "bigquery.tables.get",
    "bigquery.tables.getIamPolicy",
    "compute.autoscalers.get",
    "compute.autoscalers.list",
    "compute.backendServices.get",
    "compute.backendServices.getIamPolicy",
    "compute.backendServices.list",
    "compute.backendServices.listEffectiveTags",
    "compute.backendServices.listTagBindings",
    "compute.disks.get",
    "compute.disks.getIamPolicy",
    "compute.disks.list",
    "compute.disks.listEffectiveTags",
    "compute.disks.listTagBindings",
    "compute.diskTypes.get",
    "compute.diskTypes.list",
    "compute.instances.get",
    "compute.instances.getIamPolicy",
    "compute.instances.list",
    "compute.instances.listEffectiveTags",
    "compute.instances.listTagBindings",
    "compute.firewallPolicies.list",
    "compute.firewallPolicies.listEffectiveTags",
    "compute.firewallPolicies.listTagBindings",
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.getIamPolicy",
    "cloudfunctions.functions.list",
    "cloudfunctions.locations.list",
    "cloudfunctions.operations.get",
    "cloudfunctions.operations.list",
    "iam.roles.get",
    "iam.roles.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.listEffectiveTags",
    "iam.serviceAccounts.listTagBindings",
    "run.services.get",
    "run.services.getIamPolicy",
    "run.services.list",
    "run.services.listEffectiveTags",
    "run.services.listTagBindings",
    "secretmanager.secrets.get",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.list",
    "secretmanager.secrets.listEffectiveTags",
    "secretmanager.secrets.listTagBindings",
    "cloudsql.instances.get",
    "cloudsql.instances.getDiskShrinkConfig",
    "cloudsql.instances.list",
    "cloudsql.instances.listEffectiveTags",
    "cloudsql.instances.listTagBindings",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.getIpFilter",
    "storage.buckets.list",
    "storage.buckets.listEffectiveTags",
    "storage.buckets.listTagBindings"
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
