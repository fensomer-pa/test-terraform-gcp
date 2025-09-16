
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
