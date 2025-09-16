project_id    = "dft-ozev-evchargepoints-dev"
region        = "europe-west2"
crj_name      = "stats-intermediate-to-canonical-transform"
crj_image     = "europe-west2-docker.pkg.dev/dft-ozev-evchargepoints-dev/dft-ozev-docker-registry/stats-intermediate-to-canonical-transform"
crj_image_tag = "latest"
crj_schedule  = "0 0 4 * *"
bq_dataset_id = "canonical"
# bq_tables = {
#   local_authority = {
#     id = "dim_local_authority"
#     clustering = ["geometry"]
#   }
#   location = {
#     id = "dim_location"
#     clustering = ["location_geo", "location_id"]
#     primary_key = ["location_id"]
#   }
#   date = {
#     id = "dim_date"
#     primary_key = ["date_id"]
#   }
#   connector = {
#     id = "dim_connector"
#     clustering = ["evse_id", "connector_id"]
#     primary_key = ["connector_id"]
#   }
#   time = {
#     id = "dim_time"
#     primary_key = ["time_id"]
#   }
#   device = {
#     id = "dim_device"
#     clustering = ["device_id", "location_id"]
#     primary_key = ["device_id"]
#   }
#   evse = {
#     id = "dim_evse"
#     clustering = ["evse_geo", "evse_id", "device_id", "location_id"]
#     primary_key = ["evse_id"]
#   }
#   daily_operating_hours = {
#     id = "dim_daily_operating_hours"
#     clustering = ["location_id"]
#     primary_key = ["daily_operating_hours_id"]
#   }
#   exception_hours = {
#     id = "dim_exception_hours"
#     clustering = ["location_id"]
#     primary_key = ["exception_hours_id"]
#   }
#   evse_status_history = {
#     id = "fact_evse_status_history"
#     clustering = ["evse_id", "date_id", "status"]
#     primary_key = ["fact_evse_status_id"]
#   }
# }
# bq_table_views = [
#   "view_arcgis_export",
#   "view_evse_day_summary",
#   "view_evse_month_summary",
#   "view_evse_status_history",
#   "view_electric_power",
#   "view_contactless",
#   "view_lab_summary",
#   "view_operator_summary"
# ]


