variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "location" {
  type        = string
  default     = "europe-west2"
  description = "The GCP region where resources will be created."
}

variable "name" {
  type        = string
  description = "The name which will be assigned to the Cloud Run Job"
}

variable "image" {
  type        = string
  description = "URL of the Container image in Google Container Registry or Google Artifact Registry."
}

variable "image_tag" {
  type        = string
  description = "Tag of the Container image in Google Container Registry or Google Artifact Registry."
}

variable "timeout" {
  type        = string
  description = "Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers."
  default     = "120s"
}

variable "sa_users" {
  type        = list(string)
  description = "The list of users to be granted access to the Cloud Run service account"
  default     = []
}

variable "schedule" {
  description = "The cron schedule for the Cloud Scheduler job"
  type        = string
}
