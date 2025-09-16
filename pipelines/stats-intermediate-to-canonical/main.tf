data "google_project" "this" {
  project_id = var.project_id
}

resource "google_bigquery_table" "this" {
  for_each = var.bq_tables

  project             = var.project_id
  dataset_id          = var.bq_dataset_id
  table_id            = each.value.id
  expiration_time     = each.value.expiration_time
  clustering          = each.value.clustering

  dynamic "table_constraints" {
    for_each = length(each.value.primary_key) > 0 ? [1] : []
    content {
      primary_key {
        columns = each.value.primary_key
      }
    }
  }

  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning != null ? { (each.value.time_partitioning.type) = each.value.time_partitioning } : {}
    iterator = tp
    content {
      type          = lookup(tp.value, "type", var.bq_default_time_partition_type)
      field         = lookup(tp.value, "field", null)
      expiration_ms = lookup(tp.value, "expiration_ms", null)
    }
  }

  schema              = file("${path.module}/resources/schemas/${each.value.id}.json")
  deletion_protection = false
}

resource "google_bigquery_table" "view" {
  for_each = var.bq_table_views

  project             = var.project_id
  dataset_id          = var.bq_dataset_id
  table_id            = each.value
  deletion_protection = false

  view {
    query = templatefile("${path.module}/resources/views/${each.value}.sql", {
      GCP_PROJECT_ID = var.project_id
    })
    use_legacy_sql = false
  }
  depends_on = [
    google_bigquery_table.this
  ]
}

resource "google_service_account" "cloud_run" {
  account_id   = "dft-ozev-stats-cr-job"
  display_name = "SA for stats cloud run job"
}

resource "google_service_account_iam_binding" "cloud_run_sa_user_binding" {
  service_account_id = google_service_account.cloud_run.id
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:dft-tf-stats-pipeline@dft-ozev-evchargepoints-dev.iam.gserviceaccount.com",
    "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
  ]
}

resource "google_cloud_run_v2_job" "this" {
  name                = var.crj_name
  location            = var.region
  project             = var.project_id
  deletion_protection = false

  template {
    template {
      timeout = var.crj_timeout
      containers {
        image = format("%s:%s", var.crj_image, var.crj_image_tag)
      }
      service_account = google_service_account.cloud_run.email
    }
  }
  depends_on = [google_service_account_iam_binding.cloud_run_sa_user_binding]
}

resource "google_service_account" "scheduler" {
  account_id   = lower("dft-ozev-stats-scheduler")
  display_name = "Cloud Scheduler service account"
}

resource "google_service_account_iam_binding" "scheduler_sa_user_binding" {
  service_account_id = google_service_account.scheduler.id
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:dft-tf-stats-pipeline@dft-ozev-evchargepoints-dev.iam.gserviceaccount.com",
    "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
  ]
}

resource "google_cloud_run_v2_job_iam_member" "cloud_run_job_invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_job.this.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

resource "google_cloud_scheduler_job" "trigger_cloud_run_job" {
  name        = "${google_cloud_run_v2_job.this.name}-trigger"
  project     = var.project_id
  region      = var.region
  schedule    = var.crj_schedule
  time_zone   = "Europe/London"
  description = "Triggers Cloud Run Job for ZapMap data"

  http_target {
    uri         = "https://${google_cloud_run_v2_job.this.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.this.number}/jobs/${google_cloud_run_v2_job.this.name}:run"
    http_method = "POST"
    oauth_token {
      service_account_email = google_service_account.scheduler.email

    }
  }

  depends_on = [
    google_cloud_run_v2_job.this,
    google_cloud_run_v2_job_iam_member.cloud_run_job_invoker
  ]
}

resource "google_monitoring_notification_channel" "this" {
  for_each = var.notification_channels

  project      = var.project_id
  display_name = title(each.key)
  type         = each.value.type
  labels       = each.value.labels

  force_delete = true
}

resource "google_logging_metric" "this" {
  for_each = { for k, v in var.log_metrics : v.name => v }

  project = var.project_id
  name    = each.value.name
  filter  = each.value.filter

  metric_descriptor {
    metric_kind  = each.value.metric_kind
    value_type   = each.value.value_type
    unit         = each.value.unit
    display_name = each.value.display_name
  }
}


resource "google_monitoring_alert_policy" "this" {
  for_each = { for idx, val in var.alert_policies : val.display_name => val }

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner

  notification_channels = [
    for channel_key in each.value.notification_channel_keys :
    google_monitoring_notification_channel.this[channel_key].id
  ]


  conditions {
    display_name = "${each.value.display_name} Condition"

    condition_threshold {
      filter          = each.value.filter
      duration        = each.value.duration
      comparison      = each.value.comparison
      threshold_value = each.value.threshold_value

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      trigger {
        count = 1
      }
    }
  }
  depends_on = [
    google_monitoring_notification_channel.this,
    google_logging_metric.this
  ]
}
