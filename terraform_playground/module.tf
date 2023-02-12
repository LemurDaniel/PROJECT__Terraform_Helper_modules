

module "json_template_file" {
  source = ".././json_template_file"

  json_template_file_path = format(".config/azure_automation/%s/automation.settings.json", local.environment)

}

resource "local_file" "debug_json_out_with_appended_files" {
  content  = module.json_template_file.result_configuration_json_string
  filename = "${path.module}/module_output_processed.${module.json_template_file.base_name}.json"
}

output "name" {
  value = module.json_template_file.result_configuration
}
