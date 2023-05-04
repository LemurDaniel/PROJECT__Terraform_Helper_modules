



locals {

  files_at_file_path = {
    for file in fileset(var.folder_path, var.file_filter) :
    file => {
      file_base_name = split(".", file)[0]
      file_path      = format("%s/%s", var.folder_path, file)
    }
  }

}



module "json_template_file__depth_2" {
  source = "./depth_2"

  for_each = local.files_at_file_path

  json_template_file_path = each.value.file_path

}



locals {

  injection_results = {

    AsSingle = jsondecode(
      length(module.json_template_file__depth_2) == 0 ? "{}" : (
      values(module.json_template_file__depth_2)[0].result_configuration_json_string)
    )

    AsMap = {
      for file, config in local.files_at_file_path :
      config.file_base_name => module.json_template_file__depth_2[file].result_configuration
      if var.injection_type == "AsMap"
    }

    AsList = [
      for file, config in local.files_at_file_path :
      module.json_template_file__depth_2[file].result_configuration
      if var.injection_type == "AsList"
    ]

  }

}
