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
    "aiplatform.endpoints.get",
    "aiplatform.endpoints.list",
    "aiplatform.models.get",
    "aiplatform.models.list",
    "aiplatform.notebookRuntimeTemplates.get",
    "aiplatform.notebookRuntimeTemplates.list",
    "alloydb.clusters.get",
    "alloydb.clusters.list",
    "alloydb.instances.get",
    "alloydb.instances.list",
    "apikeys.keys.get",
    "apikeys.keys.list",
    "appengine.applications.get",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.getIamPolicy",
    "artifactregistry.repositories.list",
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.datasets.listEffectiveTags",
    "bigquery.datasets.listSharedDatasetUsage",
    "bigquery.datasets.listTagBindings",
    "bigquery.jobs.get",
    "bigquery.jobs.list",
    "bigquery.jobs.listAll",
    "bigquery.tables.get",
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.list",
    "bigquery.tables.listEffectiveTags",
    "bigquery.tables.listTagBindings",
    "bigtable.instances.get",
    "bigtable.instances.getIamPolicy",
    "bigtable.instances.list",
    "cloudasset.assets.listResource",
    "cloudasset.assets.searchAllResources",
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.getIamPolicy",
    "cloudfunctions.functions.list",
    "cloudfunctions.locations.list",
    "cloudfunctions.operations.get",
    "cloudfunctions.operations.list",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.list",
    "cloudkms.cryptoKeyVersions.get",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.keyRings.get",
    "cloudkms.keyRings.getIamPolicy",
    "cloudkms.keyRings.list",
    "cloudsql.backupRuns.get",
    "cloudsql.backupRuns.list",
    "cloudsql.databases.get",
    "cloudsql.databases.list",
    "cloudsql.instances.get",
    "cloudsql.instances.getDiskShrinkConfig",
    "cloudsql.instances.list",
    "cloudsql.instances.listEffectiveTags",
    "cloudsql.instances.listTagBindings",
    "composer.environments.get",
    "composer.environments.list",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.autoscalers.get",
    "compute.autoscalers.list",
    "compute.backendBuckets.get",
    "compute.backendBuckets.list",
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
    "compute.firewallPolicies.list",
    "compute.firewallPolicies.listEffectiveTags",
    "compute.firewallPolicies.listTagBindings",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.forwardingRules.get",
    "compute.forwardingRules.list",
    "compute.globalAddresses.get",
    "compute.globalAddresses.list",
    "compute.globalForwardingRules.get",
    "compute.globalForwardingRules.list",
    "compute.images.get",
    "compute.images.getIamPolicy",
    "compute.images.list",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.list",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.instances.get",
    "compute.instances.getIamPolicy",
    "compute.instances.list",
    "compute.instances.listEffectiveTags",
    "compute.instances.listTagBindings",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.getIamPolicy",
    "compute.instanceTemplates.list",
    "compute.machineImages.get",
    "compute.machineImages.getIamPolicy",
    "compute.machineImages.list",
    "compute.machineTypes.get",
    "compute.machineTypes.list",
    "compute.networks.get",
    "compute.networks.list",
    "compute.nodeGroups.get",
    "compute.nodeGroups.getIamPolicy",
    "compute.nodeGroups.list",
    "compute.nodeTemplates.get",
    "compute.nodeTemplates.getIamPolicy",
    "compute.nodeTemplates.list",
    "compute.projects.get",
    "compute.regions.get",
    "compute.regions.list",
    "compute.resourcePolicies.get",
    "compute.resourcePolicies.getIamPolicy",
    "compute.resourcePolicies.list",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routes.get",
    "compute.routes.list",
    "compute.securityPolicies.get",
    "compute.securityPolicies.list",
    "compute.snapshots.get",
    "compute.snapshots.getIamPolicy",
    "compute.snapshots.list",
    "compute.sslPolicies.get",
    "compute.sslPolicies.list",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy",
    "compute.subnetworks.list",
    "compute.targetHttpsProxies.get",
    "compute.targetHttpsProxies.list",
    "compute.targetPools.get",
    "compute.targetPools.list",
    "compute.targetSslProxies.get",
    "compute.targetSslProxies.list",
    "compute.targetVpnGateways.get",
    "compute.targetVpnGateways.list",
    "compute.urlMaps.get",
    "compute.urlMaps.list",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.zones.get",
    "compute.zones.list",
    "container.clusters.get",
    "container.clusters.list",
    "container.nodes.list",
    "dataplex.assets.get",
    "dataplex.assets.list",
    "dataplex.lakes.get",
    "dataplex.lakes.getIamPolicy",
    "dataplex.lakes.list",
    "dataplex.tasks.get",
    "dataplex.tasks.list",
    "dataplex.zones.get",
    "dataplex.zones.getIamPolicy",
    "dataplex.zones.list",
    "dataproc.clusters.get",
    "dataproc.clusters.list",
    "datastore.databases.get",
    "datastore.databases.list",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.policies.get",
    "dns.policies.list",
    "dns.resourceRecordSets.list",
    "essentialcontacts.contacts.list",
    "iam.roles.get",
    "iam.roles.list",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.listEffectiveTags",
    "iam.serviceAccounts.listTagBindings",
    "logging.buckets.get",
    "logging.buckets.list",
    "logging.exclusions.get",
    "logging.exclusions.list",
    "logging.logEntries.list",
    "logging.logMetrics.get",
    "logging.logMetrics.list",
    "logging.sinks.get",
    "logging.sinks.list",
    "metastore.services.get",
    "metastore.services.getIamPolicy",
    "metastore.services.list",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
    "monitoring.groups.get",
    "monitoring.groups.list",
    "monitoring.notificationChannels.get",
    "monitoring.notificationChannels.list",
    "monitoring.timeSeries.list",
    "orgpolicy.policy.get",
    "pubsub.snapshots.get",
    "pubsub.snapshots.list",
    "pubsub.subscriptions.get",
    "pubsub.subscriptions.getIamPolicy",
    "pubsub.subscriptions.list",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.list",
    "redis.clusters.get",
    "redis.clusters.list",
    "redis.instances.get",
    "redis.instances.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.tagKeys.get",
    "resourcemanager.tagKeys.list",
    "resourcemanager.tagValues.get",
    "resourcemanager.tagValues.list",
    "run.jobs.get",
    "run.jobs.getIamPolicy",
    "run.jobs.list",
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
    "serviceusage.services.get",
    "serviceusage.services.list",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.getIpFilter",
    "storage.buckets.list",
    "storage.buckets.listEffectiveTags",
    "storage.buckets.listTagBindings",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "tpu.nodes.get",
    "tpu.nodes.list",
    "vpcaccess.connectors.get",
    "vpcaccess.connectors.list",
    "workstations.workstationClusters.get",
    "workstations.workstationClusters.list",
    "workstations.workstations.get",
    "workstations.workstations.list",
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
