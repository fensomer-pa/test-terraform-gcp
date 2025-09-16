module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.5.4"
  for_each   = var.service_accounts
  project_id = var.project_id
  names      = [each.value.name]
}

module "cloud_storage" {
  source                   = "terraform-google-modules/cloud-storage/google"
  version                  = "v11.0.0"
  count                    = length(keys(var.gcs_buckets)) > 0 ? 1 : 0
  project_id               = var.project_id
  location                 = var.region
  prefix                   = var.project_id
  names                    = [for k in keys(var.gcs_buckets) : var.gcs_buckets[k].name]
  folders                  = { for k, v in var.gcs_buckets : v.name => v.folders if length(v.folders) > 0 }
  public_access_prevention = "enforced"
  randomize_suffix         = false
  set_storage_admin_roles  = false
  set_viewer_roles         = true
  set_admin_roles          = false
  set_creator_roles        = true
  storage_admins           = []
  force_destroy            = { for k, v in var.gcs_buckets : v.name => v.force_destroy }
  viewers                  = var.gcs_storage_viewers
  bucket_admins            = { for k, v in var.gcs_buckets : v.name => v.admins if length(v.viewers) > 0 }
  bucket_viewers           = { for k, v in var.gcs_buckets : v.name => v.admins if length(v.admins) > 0 }
  bucket_creators          = { for k, v in var.gcs_buckets : v.name => v.creators if length(v.creators) > 0 }
  versioning               = { for k, v in var.gcs_buckets : v.name => v.versioning }
}

module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "0.3"

  for_each      = var.artifact_registries
  project_id    = var.project_id
  location      = each.value.location
  format        = each.value.format
  repository_id = format("%s-%s-%s",var.name_prefix, var.environment, each.value.repository_id)
  members       = each.value.members
}

module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "v10.1.1"

  for_each                    = var.bigquery_datasets
  project_id                  = var.project_id
  dataset_id                  = each.value.dataset_id
  dataset_name                = each.value.dataset_name
  description                 = each.value.description
  default_table_expiration_ms = each.value.default_table_expiration_ms
  deletion_protection         = each.value.deletion_protection
  location                    = each.value.location
  delete_contents_on_destroy  = true

  access = flatten(concat(
    [
      for owner in distinct(each.value.owners) :
      merge({ role = "roles/bigquery.dataOwner" },
        (split(":", owner)[0] == "group" ? { group_by_email = split(":", owner)[1] } : { user_by_email = split(":", owner)[1] })
      )
    ],
    [
      for editor in distinct(each.value.editors) :
      merge(
        { role = "roles/bigquery.dataEditor" },
        (split(":", editor)[0] == "group" ? { group_by_email = split(":", editor)[1] } : { user_by_email = split(":", editor)[1] })
      )
    ],
    [
      for viewer in distinct(each.value.viewers) :
      merge(
        { role = "roles/bigquery.dataViewer" },
        (split(":", viewer)[0] == "group" ? { group_by_email = split(":", viewer)[1] } : { user_by_email = split(":", viewer)[1] })
      )
    ],
    [
      for viewer in distinct(concat(each.value.owners, each.value.editors, each.value.viewers)) :
      merge(
        { role = "roles/bigquery.user" },
        (split(":", viewer)[0] == "group" ? { group_by_email = split(":", viewer)[1] } : { user_by_email = split(":", viewer)[1] })
      )
    ]
  ))
}

module "wip" {
  source          = "../modules/workload-identity-pool"
  project_id      = var.project_id
  name_prefix = format("%s-%s",var.name_prefix, var.environment)
  attribute_condition = var.wip_attribute_condition
}

module "secret" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "0.8.0"
  for_each   = var.secrets
  project_id = var.project_id
  secrets = [
    {
      name           = each.value.name
      secret_data    = each.value.secret_data
      create_version = each.value.create_version
    }
  ]
  secret_accessors_list = each.value.accessors
}

#
# module "monitoring" {
#   source     = "../modules/monitoring-and-alerting"
#   project_id = var.project_id
#   notification_channels = {
#     "stats-channel" = {
#       type = "email"
#       labels = {
#         email_address = "gcp-dft-ozev-analysts@dft.gov.uk"
#       }
#     }
#   }
#   log_metrics = [
#     {
#       name         = "stats_intermediate_to_canonical_transform"
#       display_name = "Intermediate to Canonical transform error log metric"
#       filter       = <<-EOT
#     resource.type = "cloud_run_revision"
#     resource.labels.service_name = "stats-intermediate-to-canonical-transform"
#     resource.labels.location = "europe-west2"
#     severity>=ERROR
#     EOT
#       metric_kind  = "DELTA"
#       value_type   = "INT64"
#       unit         = "1"
#     }
#   ]
#   alert_policies = [
#     {
#       display_name              = "Intermediate to Canonical Transform Pipeline Error Alert"
#       filter                    = <<-EOT
#     metric.type="logging.googleapis.com/user/stats_intermediate_to_canonical_transform" AND resource.type = "cloud_run_revision"
#     EOT
#       threshold_value           = 5
#       duration                  = "300s"
#       comparison                = "COMPARISON_GT"
#       notification_channel_keys = ["stats-channel"]
#     }
#   ]
# }
