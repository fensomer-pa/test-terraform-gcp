variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "The GCP region where resources will be created."
}

variable "location" {
  type        = string
  default     = "EU"
  description = "Location for BigQuery"
}

variable "bq_dataset_id" {
  type        = string
  description = "BigQuery dataset ID where the tables will be created."
}

variable "bq_tables" {
  type = map(object({
    id              = string
    expiration_time = optional(string, null)
    primary_key     = optional(list(string), [])
    clustering      = optional(list(string), [])
    time_partitioning = optional(object({
      type          = optional(string, "MONTH")
      field         = optional(string, null)
      expiration_ms = optional(string, null)
    }), null)
  }))
  description = <<EOF
  The map of BQ tables to be provisioned
  id              = The id of the BQ table to be provisioned
  views           = The list of views to be created for BQ table
  expiration_time = The expiration time of the BQ table
  EOF
  default     = {}
}

variable "bq_table_views" {
  type        = set(string)
  description = "A map views which will need to be created where the key is the BigQuery table id."
  default     = []
}

variable "bq_default_time_partition_type" {
  type        = string
  description = "The default time partition type to set on BigQuery table when no type is supplied."
  default     = "MONTH"
}

variable "crj_name" {
  type        = string
  description = "The name which will be assigned to the Cloud Run Job"
}

variable "crj_image" {
  type        = string
  description = "URL of the Container image in Google Container Registry or Google Artifact Registry."
}

variable "crj_image_tag" {
  type        = string
  description = "Tag of the Container image in Google Container Registry or Google Artifact Registry."
}

variable "crj_timeout" {
  type        = string
  description = "Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers."
  default     = "120s"
}

variable "crj_schedule" {
  description = "The cron schedule for the Cloud Scheduler job"
  type        = string
}

variable "notification_channels" {
  type = map(object({
    type   = string
    labels = map(string)
  }))
  description = "The notification channels used to send monitoring alerts."
  default     = {}
}

variable "log_metrics" {
  type = list(object({
    name         = string
    display_name = string
    filter       = string
    metric_kind  = string
    value_type   = string
    unit         = string
  }))
  description = "The list of log metrics to be configured."
  default     = []
}

variable "alert_policies" {
  type = list(object({
    display_name              = string
    notification_channel_keys = list(string)
    threshold_value           = number
    duration                  = string
    comparison                = string
    combiner                  = optional(string, "OR")
    filter                    = string
  }))
  description = "The list for monitoring alert policies."
  default     = []
}
