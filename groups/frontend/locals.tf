locals {
  application_subnet_ids_by_az = values(zipmap(data.aws_subnet.application.*.availability_zone, data.aws_subnet.application.*.id))

  common_tags = {
    Environment    = var.environment
    Service        = var.service
    ServiceSubType = var.service_subtype
    Team           = var.team
  }

  common_resource_name = "${var.service_subtype}-${var.service}-${var.environment}"
  dns_zone = "${var.environment}.${var.dns_zone_suffix}"

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data.session-manager-bucket-name

  security_kms_keys_data      = data.vault_generic_secret.security_kms_keys.data
  ssm_kms_key_id              = local.security_kms_keys_data.session-manager-kms-key-arn

  tuxedo_services = flatten([
    for tuxedo_server_type_key, tuxedo_services in var.tuxedo_services : [
      for tuxedo_service_key, tuxedo_service_port in tuxedo_services : {
        tuxedo_server_type_key = tuxedo_server_type_key
        tuxedo_service_key     = tuxedo_service_key
        tuxedo_service_port    = tuxedo_service_port
      }
    ]
  ])

  tuxedo_service_log_groups = merge([
    for tuxedo_service_key, tuxedo_logs_list in var.tuxedo_service_logs : {
      for tuxedo_log in setproduct(tuxedo_logs_list[*].name, ["stdout", "stderr"]) : "${var.service_subtype}-${var.service}-${tuxedo_service_key}-${lower(tuxedo_log[0])}-${tuxedo_log[1]}" => {
        log_retention_in_days = lookup(tuxedo_logs_list[index(tuxedo_logs_list.*.name, tuxedo_log[0])], "log_retention_in_days", var.default_log_retention_in_days)
        kms_key_id = lookup(tuxedo_logs_list[index(tuxedo_logs_list.*.name, tuxedo_log[0])], "kms_key_id", local.logs_kms_key_id)
        tuxedo_service = tuxedo_service_key
        log_name = tuxedo_log[0]
        log_type = tuxedo_log[1]
      }
    }
  ]...)

  tuxedo_user_log_groups = merge([
    for tuxedo_service_key, tuxedo_logs_list in var.tuxedo_user_logs : {
      for tuxedo_log in tuxedo_logs_list[*].name : "${var.service_subtype}-${var.service}-${tuxedo_service_key}-${lower(tuxedo_log)}" => {
        log_retention_in_days = lookup(tuxedo_logs_list[index(tuxedo_logs_list.*.name, tuxedo_log)], "log_retention_in_days", var.default_log_retention_in_days)
        kms_key_id = lookup(tuxedo_logs_list[index(tuxedo_logs_list.*.name, tuxedo_log)], "kms_key_id", local.logs_kms_key_id)
        tuxedo_service = tuxedo_service_key
        log_name = tuxedo_log
        log_type = "individual"
      }
    }
  ]...)

  tuxedo_ngsrv_log_groups = merge([
    for tuxedo_service_key, ngsrv_logs_list in var.tuxedo_ngsrv_logs : {
      for ngsrv_log in ngsrv_logs_list[*].name : "${var.service_subtype}-${var.service}-${tuxedo_service_key}-ngsrv-${lower(ngsrv_log)}" => {
        log_retention_in_days = lookup(ngsrv_logs_list[index(ngsrv_logs_list.*.name, ngsrv_log)], "log_retention_in_days", var.default_log_retention_in_days)
        kms_key_id = lookup(ngsrv_logs_list[index(ngsrv_logs_list.*.name, ngsrv_log)], "kms_key_id", local.logs_kms_key_id)
        tuxedo_service = tuxedo_service_key
        log_name = ngsrv_log
      }
    }
  ]...)

  tuxedo_log_groups = merge(
    local.tuxedo_service_log_groups,
    local.tuxedo_user_log_groups
  )

  logs_kms_key_id = data.vault_generic_secret.kms_keys.data["logs"]
}
