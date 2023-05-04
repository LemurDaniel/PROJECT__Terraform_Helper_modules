
output "name" {
  description = "The Name of the JSON-Template-File."
  value       = local.json_template_file_name
}

output "base_name" {
  description = "The Base Name of the JSON-Template-File."
  value       = local.json_template_file_base_name
}

output "directory" {
  description = "Outputs the absolute path to the directory where the JSON-Template resides."
  value       = local.json_template_file_directory
}

output "result_configuration_json_string" {
  description = "Outputs the resulting configuration of the JSON-Template with all injected values as a JSON-string"
  value       = local.result_configuration
}

output "result_configuration" {
  description = "Outputs the resulting configuration of the JSON-Template with all injected values as a terrform object"
  value       = jsondecode(local.result_configuration)
}




output "debug" {
  value = module.json_template_subfiles
}
