variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "The GCP region where resources will be created."
}
