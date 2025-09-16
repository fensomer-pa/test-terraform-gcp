variable "project_id" {
  type        = string
  description = "The project id where GCP resources will be created"
}

variable "environment" {
  type        = string
  description = "The environment where the GCP resources will be created"
}

variable "region" {
  type        = string
  description = "The region where GCP resources will be created"
  default     = "europe-west2"
}

variable "name_prefix" {
  type = string
  description = "This is a prefix which is prepended to GCP resources"
}

variable "wip_attribute_condition" {
  type        = string
  description = "Workload Identity Pool Provider attribute condition expression. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider#attribute_condition)"
}

variable "location" {
  type    = string
  default = "europe-west1"
}

variable "artifact_registries" {
  type = map(object({
    location      = string
    format        = string
    repository_id = string
    members       = optional(map(list(string)), {})
  }))
  description = "The map of GCP Artifact Registries to be provisioned."
  default     = {}
}

variable "bigquery_datasets" {
  type = map(object({
    dataset_id                  = string
    dataset_name                = string
    description                 = string
    default_table_expiration_ms = optional(number, null)
    deletion_protection         = optional(bool, true)
    location                    = string
    owners                      = optional(list(string), [])
    editors                     = optional(list(string), [])
    viewers                     = optional(list(string), [])
    tables = optional(list(object({
      table_id                 = string,
      description              = string,
      table_name               = string,
      schema                   = string,
      clustering               = optional(list(string), []),
      require_partition_filter = optional(bool, false),
      time_partitioning = optional(object({
        expiration_ms = string,
        field         = string,
        type          = string,
      })),
      range_partitioning = optional(object({
        field = string,
        range = object({
          start    = string,
          end      = string,
          interval = string,
        }),
      })),
      expiration_time     = string,
      deletion_protection = optional(bool, true),
      labels              = map(string),
    })), [])
  }))
  description = "The map of big query datasets to be provisioned."
  default     = {}
}

variable "bigquery_datasets_env_overrides" {
  type = map(object({
    owners                      = optional(list(string), [])
    editors                     = optional(list(string), [])
    viewers                     = optional(list(string), [])
  }))
  default = {}
}

variable "gcs_buckets" {
  type = map(object({
    name          = string
    folders       = list(string)
    admins        = optional(string, "")
    creators      = optional(string, "")
    viewers       = optional(string, "")
    versioning    = optional(bool, true)
    force_destroy = optional(bool, false)
  }))
  description = <<EOF
  The map of GCS buckets to be provisioned
  name          = The name of the GCS bucket to be provisioned
  folders       = The list folder to be created within the GCS bucket
  admins        = The comma separated list of groups to be granted admins access
  creators      = The comma separated list of groups to be granted creators access
  viewers       = The comma separated list of groups to be granted viewers access
  versioning    = If true, object versioning will be enabled on the GCS Bucket
  force_destroy = If true, Terraform will be authorised the bucket
  EOF
  default     = {}
}

variable "gcs_storage_viewers" {
  description = "IAM-style members who will be granted roles/storage.objectViewer on all buckets."
  type        = list(string)
  default     = []
}

variable "service_accounts" {
  type = map(object({
    name         = string
    description  = string
    display_name = optional(string, null)
  }))
  description = "The map of service accounts to be provisioned."
  default     = {}
}

variable "secrets" {
  type = map(object({
    name = string
    secret_data : optional(string, null),
    next_rotation_time : optional(string, null),
    rotation_period : optional(string, null),
    create_version : optional(bool, false)
    accessors = optional(list(string), [])
  }))
  description = <<EOF
  The map of secrets to be provisioned
  name               = This must be unique within the project.
  secret_data        = The data to be stored within the secret
  next_rotation_time = Timestamp in UTC at which the Secret is scheduled to rotate
  rotation_period    = The Duration between rotation notifications. Must be in seconds and at least 3600s (1h) and at most 3153600000s (100 years).
  create_version     = If true, a secret version will be created
  accessors          = The list of users, groups or service accounts allowed to access the secrets
  EOF
  default     = {}
}
