variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
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
