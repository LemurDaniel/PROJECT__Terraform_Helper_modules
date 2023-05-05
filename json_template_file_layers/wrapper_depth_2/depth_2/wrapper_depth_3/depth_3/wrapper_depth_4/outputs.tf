
output "injection_result" {
  description = "Outputs injection result from the wrapper of all subfiles."
  value = local.injection_results[var.injection_type]
}
