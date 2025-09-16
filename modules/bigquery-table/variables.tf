variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}


variable "location" {
  type        = string
  default     = "EU"
  description = "Location for BigQuery"
}

variable "dataset_id" {
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

variable "table_views" {
  type        = set(string)
  description = "A map views which will need to be created where the key is the BigQuery table id."
  default     = []
}

variable "default_time_partition_type" {
  type        = string
  description = "The default time partition type to set on BigQuery table when no type is supplied."
  default     = "MONTH"
}
