# ------------------------------
# viberoll-infra/modules/waf/outputs.tf
# ------------------------------

output "waf_arn" {
  value = aws_wafv2_web_acl.waf.arn
}
