data "google_project" "this" {
  project_id = var.project_id
}

resource "google_service_account" "cloud_run" {
  account_id   = "dft-ozev-${var.name}-cr-job"
  display_name = "SA for stats cloud run job"
}

resource "google_service_account_iam_binding" "cloud_run_sa_user_binding" {
  service_account_id = google_service_account.cloud_run.id
  role               = "roles/iam.serviceAccountUser"
  members            = var.sa_users
}

resource "google_cloud_run_v2_job" "this" {
  name                = var.name
  location            = var.location
  project             = var.project_id
  deletion_protection = false

  template {
    template {
      timeout = var.timeout
      containers {
        image = format("%s:%s", var.image, var.image_tag)
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
  members            = var.sa_users
}

resource "google_cloud_run_v2_job_iam_member" "cloud_run_job_invoker" {
  location = var.location
  project  = var.project_id
  name     = google_cloud_run_v2_job.this.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

resource "google_cloud_scheduler_job" "trigger_cloud_run_job" {
  name        = "${google_cloud_run_v2_job.this.name}-trigger"
  project     = var.project_id
  region      = var.location
  schedule    = var.schedule
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
