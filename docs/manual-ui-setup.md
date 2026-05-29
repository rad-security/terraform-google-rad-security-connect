# Connecting Google Cloud to RAD Security — Manual (UI) Setup

This guide reproduces, by hand in the Google Cloud Console, everything the
`terraform-google-rad-security-connect` module does automatically. Use it when
you can't run Terraform but have **Owner / admin access** to the Google Cloud
project you want to connect.

The connection uses **Workload Identity Federation** — RAD authenticates from
its own AWS role into your project. No service-account keys are created or
stored anywhere.

---

## What you will create

| # | Object | Name / ID |
|---|--------|-----------|
| 1 | Custom IAM role (read-only) | `rad_security_cloud_connect_role` |
| 2 | Service account | `rad-security-cloud-connect` |
| 3 | Project IAM binding | custom role → service account |
| 4 | Workload Identity Pool | `rad-security-identity-pool` |
| 5 | Workload Identity Pool AWS provider | `rad-security-aws-provider` |
| 6 | Service-account access binding | federated AWS identity → service account |
| 7 | Register the connection in the RAD Security UI | — |

### Fixed values used throughout (do not change)

These identify RAD's AWS connector and must match exactly:

| Value | Setting |
|-------|---------|
| **RAD AWS account ID** | `955322216602` |
| **RAD AWS role name** | `rad-security-connector` |

### Values you will need from your own project

Find these on the Google Cloud Console **home/dashboard** (or **IAM & Admin →
Settings**):

- **Project ID** — e.g. `my-production-project`
- **Project number** — the numeric ID, e.g. `123456789012`

Keep both handy; several steps need them.

---

## Step 0 — Enable the required APIs

**Console → APIs & Services → Enabled APIs & services → + ENABLE APIS AND SERVICES**

Search for and enable each of these (if not already enabled):

- **Identity and Access Management (IAM) API** (`iam.googleapis.com`)
- **IAM Service Account Credentials API** (`iamcredentials.googleapis.com`)
- **Cloud Resource Manager API** (`cloudresourcemanager.googleapis.com`)
- **Security Token Service API** (`sts.googleapis.com`)

> RAD reads a wide range of resource types (Compute, GKE, Cloud SQL, BigQuery,
> Storage, KMS, Pub/Sub, etc.). You do **not** need to enable every one of those
> APIs for setup — but inventory for a given service will only appear if that
> service's API is enabled in the project.

---

## Step 1 — Create the custom IAM role

This is the read-only role RAD's service account will use. It contains ~250
`get`/`list` permissions, so creating it by clicking checkboxes is slow and
error-prone. **Two options:**

### Option A (recommended): Cloud Shell — one command

Cloud Shell is part of the Console (terminal icon, top-right) and needs no local
install. It is *not* Terraform — it's the standard `gcloud` CLI.

1. Open **Cloud Shell**.
2. Create the role definition file — paste this whole block and press Enter:

   ```bash
   cat > rad-role.yaml <<'EOF'
   title: "RAD Security Cloud Connect Role"
   description: "RAD Security's Google Cloud Role to retrieve Google Cloud resources"
   stage: "GA"
   includedPermissions:
   - aiplatform.endpoints.get
   - aiplatform.endpoints.list
   - aiplatform.models.get
   - aiplatform.models.list
   - aiplatform.notebookRuntimeTemplates.get
   - aiplatform.notebookRuntimeTemplates.list
   - alloydb.clusters.get
   - alloydb.clusters.list
   - alloydb.instances.get
   - alloydb.instances.list
   - apikeys.keys.get
   - apikeys.keys.list
   - appengine.applications.get
   - artifactregistry.repositories.get
   - artifactregistry.repositories.getIamPolicy
   - artifactregistry.repositories.list
   - bigquery.datasets.get
   - bigquery.datasets.getIamPolicy
   - bigquery.datasets.listEffectiveTags
   - bigquery.datasets.listSharedDatasetUsage
   - bigquery.datasets.listTagBindings
   - bigquery.jobs.get
   - bigquery.jobs.list
   - bigquery.jobs.listAll
   - bigquery.tables.get
   - bigquery.tables.getIamPolicy
   - bigquery.tables.list
   - bigquery.tables.listEffectiveTags
   - bigquery.tables.listTagBindings
   - bigtable.instances.get
   - bigtable.instances.getIamPolicy
   - bigtable.instances.list
   - cloudasset.assets.listResource
   - cloudasset.assets.searchAllResources
   - cloudfunctions.functions.get
   - cloudfunctions.functions.getIamPolicy
   - cloudfunctions.functions.list
   - cloudfunctions.locations.list
   - cloudfunctions.operations.get
   - cloudfunctions.operations.list
   - cloudkms.cryptoKeys.get
   - cloudkms.cryptoKeys.getIamPolicy
   - cloudkms.cryptoKeys.list
   - cloudkms.cryptoKeyVersions.get
   - cloudkms.cryptoKeyVersions.list
   - cloudkms.keyRings.get
   - cloudkms.keyRings.getIamPolicy
   - cloudkms.keyRings.list
   - cloudsql.backupRuns.get
   - cloudsql.backupRuns.list
   - cloudsql.databases.get
   - cloudsql.databases.list
   - cloudsql.instances.get
   - cloudsql.instances.getDiskShrinkConfig
   - cloudsql.instances.list
   - cloudsql.instances.listEffectiveTags
   - cloudsql.instances.listTagBindings
   - composer.environments.get
   - composer.environments.list
   - compute.addresses.get
   - compute.addresses.list
   - compute.autoscalers.get
   - compute.autoscalers.list
   - compute.backendBuckets.get
   - compute.backendBuckets.list
   - compute.backendServices.get
   - compute.backendServices.getIamPolicy
   - compute.backendServices.list
   - compute.backendServices.listEffectiveTags
   - compute.backendServices.listTagBindings
   - compute.disks.get
   - compute.disks.getIamPolicy
   - compute.disks.list
   - compute.disks.listEffectiveTags
   - compute.disks.listTagBindings
   - compute.diskTypes.get
   - compute.diskTypes.list
   - compute.firewallPolicies.list
   - compute.firewallPolicies.listEffectiveTags
   - compute.firewallPolicies.listTagBindings
   - compute.firewalls.get
   - compute.firewalls.list
   - compute.forwardingRules.get
   - compute.forwardingRules.list
   - compute.globalAddresses.get
   - compute.globalAddresses.list
   - compute.globalForwardingRules.get
   - compute.globalForwardingRules.list
   - compute.images.get
   - compute.images.getIamPolicy
   - compute.images.list
   - compute.instanceGroupManagers.get
   - compute.instanceGroupManagers.list
   - compute.instanceGroups.get
   - compute.instanceGroups.list
   - compute.instances.get
   - compute.instances.getIamPolicy
   - compute.instances.list
   - compute.instances.listEffectiveTags
   - compute.instances.listTagBindings
   - compute.instanceTemplates.get
   - compute.instanceTemplates.getIamPolicy
   - compute.instanceTemplates.list
   - compute.machineImages.get
   - compute.machineImages.getIamPolicy
   - compute.machineImages.list
   - compute.machineTypes.get
   - compute.machineTypes.list
   - compute.networks.get
   - compute.networks.list
   - compute.nodeGroups.get
   - compute.nodeGroups.getIamPolicy
   - compute.nodeGroups.list
   - compute.nodeTemplates.get
   - compute.nodeTemplates.getIamPolicy
   - compute.nodeTemplates.list
   - compute.projects.get
   - compute.regions.get
   - compute.regions.list
   - compute.resourcePolicies.get
   - compute.resourcePolicies.getIamPolicy
   - compute.resourcePolicies.list
   - compute.routers.get
   - compute.routers.list
   - compute.routes.get
   - compute.routes.list
   - compute.securityPolicies.get
   - compute.securityPolicies.list
   - compute.snapshots.get
   - compute.snapshots.getIamPolicy
   - compute.snapshots.list
   - compute.sslPolicies.get
   - compute.sslPolicies.list
   - compute.subnetworks.get
   - compute.subnetworks.getIamPolicy
   - compute.subnetworks.list
   - compute.targetHttpsProxies.get
   - compute.targetHttpsProxies.list
   - compute.targetPools.get
   - compute.targetPools.list
   - compute.targetSslProxies.get
   - compute.targetSslProxies.list
   - compute.targetVpnGateways.get
   - compute.targetVpnGateways.list
   - compute.urlMaps.get
   - compute.urlMaps.list
   - compute.vpnGateways.get
   - compute.vpnGateways.list
   - compute.vpnTunnels.get
   - compute.vpnTunnels.list
   - compute.zones.get
   - compute.zones.list
   - container.clusters.get
   - container.clusters.list
   - container.nodes.list
   - dataplex.assets.get
   - dataplex.assets.list
   - dataplex.lakes.get
   - dataplex.lakes.getIamPolicy
   - dataplex.lakes.list
   - dataplex.tasks.get
   - dataplex.tasks.list
   - dataplex.zones.get
   - dataplex.zones.getIamPolicy
   - dataplex.zones.list
   - dataproc.clusters.get
   - dataproc.clusters.list
   - datastore.databases.get
   - datastore.databases.list
   - dns.managedZones.get
   - dns.managedZones.list
   - dns.policies.get
   - dns.policies.list
   - dns.resourceRecordSets.list
   - essentialcontacts.contacts.list
   - iam.roles.get
   - iam.roles.list
   - iam.serviceAccountKeys.get
   - iam.serviceAccountKeys.list
   - iam.serviceAccounts.get
   - iam.serviceAccounts.getIamPolicy
   - iam.serviceAccounts.list
   - iam.serviceAccounts.listEffectiveTags
   - iam.serviceAccounts.listTagBindings
   - logging.buckets.get
   - logging.buckets.list
   - logging.exclusions.get
   - logging.exclusions.list
   - logging.logEntries.list
   - logging.logMetrics.get
   - logging.logMetrics.list
   - logging.sinks.get
   - logging.sinks.list
   - metastore.services.get
   - metastore.services.getIamPolicy
   - metastore.services.list
   - monitoring.alertPolicies.get
   - monitoring.alertPolicies.list
   - monitoring.groups.get
   - monitoring.groups.list
   - monitoring.notificationChannels.get
   - monitoring.notificationChannels.list
   - monitoring.timeSeries.list
   - orgpolicy.policy.get
   - pubsub.snapshots.get
   - pubsub.snapshots.list
   - pubsub.subscriptions.get
   - pubsub.subscriptions.getIamPolicy
   - pubsub.subscriptions.list
   - pubsub.topics.get
   - pubsub.topics.getIamPolicy
   - pubsub.topics.list
   - redis.clusters.get
   - redis.clusters.list
   - redis.instances.get
   - redis.instances.list
   - resourcemanager.projects.get
   - resourcemanager.projects.getIamPolicy
   - resourcemanager.tagKeys.get
   - resourcemanager.tagKeys.list
   - resourcemanager.tagValues.get
   - resourcemanager.tagValues.list
   - run.jobs.get
   - run.jobs.getIamPolicy
   - run.jobs.list
   - run.services.get
   - run.services.getIamPolicy
   - run.services.list
   - run.services.listEffectiveTags
   - run.services.listTagBindings
   - secretmanager.secrets.get
   - secretmanager.secrets.getIamPolicy
   - secretmanager.secrets.list
   - secretmanager.secrets.listEffectiveTags
   - secretmanager.secrets.listTagBindings
   - serviceusage.services.get
   - serviceusage.services.list
   - storage.buckets.get
   - storage.buckets.getIamPolicy
   - storage.buckets.getIpFilter
   - storage.buckets.list
   - storage.buckets.listEffectiveTags
   - storage.buckets.listTagBindings
   - storage.objects.get
   - storage.objects.getIamPolicy
   - storage.objects.list
   - tpu.nodes.get
   - tpu.nodes.list
   - vpcaccess.connectors.get
   - vpcaccess.connectors.list
   - workstations.workstationClusters.get
   - workstations.workstationClusters.list
   - workstations.workstations.get
   - workstations.workstations.list
   EOF
   ```

3. Create the role (replace `YOUR_PROJECT_ID`):

   ```bash
   gcloud iam roles create rad_security_cloud_connect_role \
     --project=YOUR_PROJECT_ID \
     --file=rad-role.yaml
   ```

> If `gcloud` rejects a permission because the matching API isn't enabled in
> your project, either enable that API first or temporarily remove that line
> from the YAML. You can add it back later with
> `gcloud iam roles update rad_security_cloud_connect_role --project=YOUR_PROJECT_ID --file=rad-role.yaml`.

### Option B: Pure Console (no Cloud Shell)

1. **Console → IAM & Admin → Roles → + CREATE ROLE**
2. **Title:** `RAD Security Cloud Connect Role`
3. **ID:** `rad_security_cloud_connect_role`
4. **Description:** `RAD Security's Google Cloud Role to retrieve Google Cloud resources`
5. **Role launch stage:** `General Availability`
6. Click **+ ADD PERMISSIONS** and add every permission listed in the YAML
   block above. The filter box accepts one permission name at a time — paste a
   name, tick its checkbox, repeat. (This is tedious; Option A is strongly
   recommended.)
7. **CREATE**.

---

## Step 2 — Create the service account

**Console → IAM & Admin → Service Accounts → + CREATE SERVICE ACCOUNT**

1. **Service account name:** `RAD Security Cloud Connect`
2. **Service account ID:** `rad-security-cloud-connect`
   - The full email becomes:
     `rad-security-cloud-connect@YOUR_PROJECT_ID.iam.gserviceaccount.com`
3. Click **CREATE AND CONTINUE**.
4. **Do NOT grant roles on this screen** and **do NOT create any keys.**
   (The role is granted in Step 3; keys are never used.)
5. Click **DONE**.

> Record the service-account email — you'll need it in Steps 3, 6, and 7.

---

## Step 3 — Grant the custom role to the service account

**Console → IAM & Admin → IAM → + GRANT ACCESS**

1. **New principals:**
   `rad-security-cloud-connect@YOUR_PROJECT_ID.iam.gserviceaccount.com`
2. **Assign role:** select **RAD Security Cloud Connect Role** (under "Custom").
3. **SAVE**.

---

## Step 4 — Create the Workload Identity Pool

**Console → IAM & Admin → Workload Identity Federation → CREATE POOL**

1. **Name:** `RAD Security Identity Pool`
2. **Pool ID:** `rad-security-identity-pool`
3. **Description:** `Identity pool for RAD Security`
4. **Enabled:** on.
5. Click **CONTINUE** (the provider is added in the next step — don't finish
   the wizard without adding the provider).

---

## Step 5 — Add the AWS provider to the pool

On the "Add a provider to pool" screen (continuing from Step 4, or **Workload
Identity Federation → your pool → ADD PROVIDER**):

1. **Select a provider:** **AWS**
2. **Provider name:** `RAD Security AWS Provider`
3. **Provider ID:** `rad-security-aws-provider`
4. **AWS Account ID:** `955322216602`
5. Click **CONTINUE** to reach **Configure provider attributes**.
6. **Attribute mapping** — set exactly these two rows (the first is the default;
   add the second with **+ ADD MAPPING**):

   | Google attribute | AWS assertion |
   |------------------|---------------|
   | `google.subject` | `assertion.arn` |
   | `attribute.aws_account` | `assertion.account` |

7. **Attribute conditions** — paste this CEL expression:

   ```
   assertion.account == '955322216602' && assertion.arn.contains('rad-security-connector')
   ```

8. **SAVE**.

---

## Step 6 — Let the federated AWS identity use the service account

This grants **Workload Identity User** on the service account to any RAD AWS
identity that came through the pool. Easiest path:

**Console → IAM & Admin → Workload Identity Federation → open
`rad-security-identity-pool` → GRANT ACCESS**

1. Choose **Grant access using Service Account impersonation**.
2. **Service account:** `rad-security-cloud-connect@YOUR_PROJECT_ID.iam.gserviceaccount.com`
3. **Principals in the pool:** choose
   **`attribute.aws_account`** with value **`955322216602`**
   (i.e. "Only identities matching the filter" → attribute `aws_account` →
   `955322216602`).
4. **SAVE**, then **DISMISS** the downloaded config (you don't need the JSON
   file it offers).

This produces the binding:

```
principalSet://iam.googleapis.com/projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/rad-security-identity-pool/attribute.aws_account/955322216602
  → roles/iam.workloadIdentityUser
  on rad-security-cloud-connect@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

> **Alternative (Service Accounts page):** IAM & Admin → Service Accounts →
> open `rad-security-cloud-connect` → **PERMISSIONS** tab → **GRANT ACCESS** →
> add the `principalSet://…` value above as the principal and role
> **Workload Identity User**.

---

## Step 7 — Register the connection in the RAD Security UI

The Terraform module's final step registers the project with RAD. Do this in
the **RAD Security console** (not Google Cloud). RAD needs three values:

| RAD field | Value to enter |
|-----------|----------------|
| **Service account email** | `rad-security-cloud-connect@YOUR_PROJECT_ID.iam.gserviceaccount.com` |
| **Workload Identity Pool provider name** | `projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/rad-security-identity-pool/providers/rad-security-aws-provider` |
| **Project number** | `YOUR_PROJECT_NUMBER` |

In RAD Security: go to the **Google Cloud integration / Add connection** flow
and paste those three values. (If your RAD console doesn't expose a manual form,
send these three values to your RAD Security contact and they'll complete the
registration.)

Substitute `YOUR_PROJECT_ID` and `YOUR_PROJECT_NUMBER` with your real values —
**the provider name uses the numeric project _number_, not the project ID.**

---

## Verification checklist

- [ ] Custom role `rad_security_cloud_connect_role` exists (IAM & Admin → Roles).
- [ ] Service account `rad-security-cloud-connect` exists, **with no keys**.
- [ ] Project IAM shows the service account holding **RAD Security Cloud Connect Role**.
- [ ] Workload Identity Pool `rad-security-identity-pool` is **Enabled**.
- [ ] Provider `rad-security-aws-provider` shows AWS account `955322216602` and
      the attribute condition above.
- [ ] Service account → Permissions shows a `principalSet://…/attribute.aws_account/955322216602`
      principal with **Workload Identity User**.
- [ ] RAD Security shows the connection as **connected / healthy** after Step 7.

---

## Notes & troubleshooting

- **Read-only:** every permission in the role is a `get`/`list`/`getIamPolicy`
  call. RAD cannot create, modify, or delete anything in your project.
- **No long-lived credentials:** Workload Identity Federation issues short-lived
  tokens on demand. There is intentionally no service-account key.
- **Project scope only:** this connects a single project. Repeat the whole guide
  per project; organization-level connection is not supported by this flow.
- **"Permission denied" when creating the role (Option A/B):** you need
  `iam.roles.create` — i.e. **Owner** or **Role Administrator** on the project.
- **Connection unhealthy in RAD:** re-check that the provider name in Step 7
  uses the **project number**, that the AWS account ID is exactly
  `955322216602`, and that the attribute condition references
  `rad-security-connector`.
