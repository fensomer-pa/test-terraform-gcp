resource "google_bigquery_table" "this" {
  for_each = var.bq_tables

  project             = var.project_id
  dataset_id          = var.dataset_id
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
      type          = lookup(tp.value, "type", var.default_time_partition_type)
      field         = lookup(tp.value, "field", null)
      expiration_ms = lookup(tp.value, "expiration_ms", null)
    }
  }

  schema              = file("${path.module}/resources/schemas/${each.value.id}.json")
  deletion_protection = false
}

resource "google_bigquery_table" "view" {
  for_each = var.table_views

  project             = var.project_id
  dataset_id          = var.dataset_id
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
