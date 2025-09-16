resource "random_id" "this" {
  byte_length = 2
}

resource "google_iam_workload_identity_pool" "this" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = format("%s-pdr-%s", var.name_prefix, random_id.this.hex)
  display_name              = var.display_name
  description               = var.description
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "this" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = format("%s-pdr-%s", var.name_prefix, random_id.this.hex)
  display_name                       = var.provider_display_name
  description                        = var.provider_description
  attribute_condition                = var.attribute_condition
  attribute_mapping                  = var.attribute_mapping
  oidc {
    allowed_audiences = var.allowed_audiences
    issuer_uri        = var.issuer_uri
  }
}
