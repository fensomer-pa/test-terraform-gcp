project_id  = "dft-ozev-evchargepoints-test"
region      = "europe-west2"
environment = "test"
artifact_registries = {
  docker = {
    repository_id = "dft-ozev-docker-registry"
    location      = "europe-west2"
    format        = "DOCKER"
    members = {
      readers = [
        "serviceAccount:service-288176795330@serverless-robot-prod.iam.gserviceaccount.com"
      ]
      writers = [
        "serviceAccount:dft-tf-stats-pipeline@dft-ozev-evchargepoints-test.iam.gserviceaccount.com"
      ]
    }
  }
}
gcs_buckets = {
  additional_files_clean = {
    name = "additional-data-sources-clean"
    folders = [
      "dno",
      "dno_license_areas",
      "local_authority_boundaries",
      "local_authority_regions",
      "msa",
      "parliamentary_constituencies",
      "ruc",
      "srn"
    ]
  }
}
service_accounts = {
  arcgis_dashboard = {
    name        = "dft-ozev-arcgis-dashboard"
    description = "Service account for ArcGIS dashboard access"
  }
  power_bi = {
    name        = "dft-ozev-power-bi-dashboard"
    description = "Service account for PowerBI dashboard access"
  }
}
secrets = {
  arcgis_dashboard = {
    name = "dft-ozev-arcgis-dashboard-sa-key-file"
    accessors = [
      "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
    ]
  }
  power_bi = {
    name = "dft-ozev-power-bi-dashboard-sa-key-file"
    accessors = [
      "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
    ]
  }
}
bigquery_datasets = {
  additional_data_sources = {
    dataset_id          = "additional_data_sources"
    dataset_name        = "The dataset containing data sourced from additional data sources"
    description         = "The dataset containing data sourced from external data sources by the stats team."
    location            = "europe-west2"
    deletion_protection = false
    owners = [
      "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
    ]
    viewers = [
      "serviceAccount:dft-ozev-stats-cr-job@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "serviceAccount:dft-tf-de-pipeline@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
    ]
  }
  intermediate = {
    dataset_id          = "intermediate"
    dataset_name        = "The intermediate (Silver) dataset"
    description         = "The intermediate (Silver) will contain the raw data which has been restructured for ease of use, and optimized performance for storage and querying."
    location            = "europe-west2"
    deletion_protection = false
    owners = [
      "serviceAccount:dft-ozev-de-cf@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "serviceAccount:dft-tf-de-pipeline@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "group:gcp-dft-ozev-pa-developers@dft.gov.uk",
      "serviceAccount:service-288176795330@gcp-sa-dataplex.iam.gserviceaccount.com"
    ]
    viewers = [
      "serviceAccount:dft-ozev-stats-cr-job@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "serviceAccount:dft-tf-stats-pipeline@dft-ozev-evchargepoints-test.iam.gserviceaccount.com"
    ]
  }
  canonical = {
    dataset_id          = "canonical"
    dataset_name        = "The canonical (Gold) dataset"
    description         = "The canonical (Gold) layer will contain a subset of the data further transformed to be easier to use and in the format needed for visualisation."
    location            = "europe-west2"
    deletion_protection = false
    owners = [
      "serviceAccount:dft-ozev-stats-cr-job@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "serviceAccount:dft-tf-stats-pipeline@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "group:gcp-dft-ozev-pa-developers@dft.gov.uk"
    ]
    viewers = [
      "serviceAccount:dft-ozev-arcgis-dashboard@dft-ozev-evchargepoints-test.iam.gserviceaccount.com",
      "serviceAccount:dft-ozev-power-bi-dashboard@dft-ozev-evchargepoints-test.iam.gserviceaccount.com"
    ]
  }
}
wip_attribute_condition = <<EOT
(attribute.environment =="test" && (attribute.ref == "refs/heads/main" || attribute.ref.contains("release")))
EOT
