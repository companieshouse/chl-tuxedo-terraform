resource "aws_cloudwatch_log_group" "logs" {
  for_each = local.tuxedo_log_groups

  name              = each.key
  retention_in_days = each.value.log_retention_in_days
  kms_key_id        = each.value.kms_key_id

  tags = merge(local.common_tags, {
    TuxedoServerType = each.value.tuxedo_service
    TuxedoLogName = each.value.log_name
    TuxedoLogType = each.value.log_type
  })
}