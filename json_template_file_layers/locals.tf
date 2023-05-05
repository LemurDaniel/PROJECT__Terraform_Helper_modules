
locals {

  json_template_file_path_abs  = abspath(var.json_template_file_path) #abspath(format("%s/%s", path.root, var.json_template_file_path))
  json_template_file_directory = join("/", slice(split("/", local.json_template_file_path_abs), 0, length(split("/", local.json_template_file_path_abs)) - 1))

  json_template_file_name      = split("/", local.json_template_file_path_abs)[length(split("/", local.json_template_file_path_abs)) - 1]
  json_template_file_base_name = join(".", slice(split(".", local.json_template_file_name), 0, length(split(".", local.json_template_file_name)) - 1))

  # Read the JSON-File in which certain files will be injected as maps or lists.
  json_template_file_content = file(local.json_template_file_path_abs) # Not JSON-Decoded for injecting later into JSON-String!

}


locals {

  # Gets for any regexmatch the replacement_identiert ('{{path}}' sequence in json-template) and the contained filepath as an array.
  regex_captures_replace_as_map = {
    # Caputes formats of "{{./some_path}}" => !Inludes Quotations, to replace the whole string with an json-object.
    for replace_identifier in distinct(regexall("\"{{[^{}]+}}\"", local.json_template_file_content)) :
    replace(
      replace_identifier, "/([\\[\\]\\*])/", "\\$1"
      ) => {
      # The path to the to be inserted Json-Files, as an array in the JSON-Template-file.
      file_path_array = split("/", replace(replace_identifier, "/[{}\"]+/", ""))
      injection_type  = "AsMap"
    }
  }

  # Gets for any regexmatch the replacement_identiert ('[[path]]' sequence in json-template) and the contained filepath as an array.
  regex_captures_replace_as_list = {
    # Caputes formats of "[[./some_path]]" => !Inludes Quotations, to replace the whole string with an json-list.
    for replace_identifier in distinct(regexall("\"\\[\\[[^\\[\\]]+\\]\\]\"", local.json_template_file_content)) :
    replace(
      replace_identifier, "/([\\[\\]\\*])/", "\\$1"
      ) => {
      # The path to the to be inserted Json-Files, as an array in the JSON-Template-file.
      file_path_array = split("/", replace(replace_identifier, "/[\\[\\]\"]+/", ""))
      injection_type  = "AsList"
    }
  }


  # Convert all the read values from the JSON-Template to file_path, the file_filter and injection_type
  regex_captures_replace_correct_filepath = {
    for replace_identifier, config in merge(local.regex_captures_replace_as_map, local.regex_captures_replace_as_list) :
    replace_identifier => {
      folder_path = format("%s/%s", local.json_template_file_directory, join("/", slice(config.file_path_array, 0, length(config.file_path_array) - 1)))
      file_filter = config.file_path_array[length(config.file_path_array) - 1]
      injection_type = config.injection_type == "AsList" ? "AsList" : (
        can(regex("[/*]+", config.file_path_array[length(config.file_path_array) - 1])) ? "AsMap" : "AsSingle"
      )
    }
  }

}

####################################################################################################
###### Either 'json_template_file__wrapper_depth_X' or 'locals for injecting' for last depth layer injection
####################################################################################################

module "json_template_subfiles" {
  source = "./wrapper_depth_2"

  for_each = local.regex_captures_replace_correct_filepath

  folder_path    = each.value.folder_path
  file_filter    = each.value.file_filter
  injection_type = each.value.injection_type

}
locals {
  final_injection_identifier_to_injection_map = zipmap(
    keys(module.json_template_subfiles),
    values(module.json_template_subfiles)[*].injection_result
  )
}

/*
locals {

  # Locals for injecting

  injection_results = {


    AsSingle = {
      for replace_identifier, config in local.regex_captures_replace_correct_filepath :
      replace_identifier => [
        for file in fileset(config.folder_path, config.file_filter) :
        jsondecode(file(format("%s/%s", config.folder_path, file)))
      ][0]
      if config.injection_type == "AsSingle"
    }

    # Read all files for each replacement with the injection type 'AsMap', as replace_identifier => { file_name => filecontent_jsondecoded }
    AsMap = {
      for replace_identifier, config in local.regex_captures_replace_correct_filepath :
      replace_identifier => {
        for file in fileset(config.folder_path, config.file_filter) :
        split(".", file)[0] => jsondecode(file(format("%s/%s", config.folder_path, file)))
      }
      if config.injection_type == "AsMap"
    }


    # Read all files for each replacement with the injection type 'AsList', as replace_identifier => [ filecontent_jsondecoded ]
    AsList = {
      for replace_identifier, config in local.regex_captures_replace_correct_filepath :
      replace_identifier => [
        for file in fileset(config.folder_path, config.file_filter) :
        jsondecode(file(format("%s/%s", config.folder_path, file)))
      ]
      if config.injection_type == "AsList"
    }


  }

  final_injection_identifier_to_injection_map = merge(values(local.injection_results)...)

}
*/

####################################################################################################
###### Create JSON-File with all Injections
####################################################################################################

locals {

  result_configuration = join("\n",
    # Splits the String into lines and checks on each line for possible replacment, then joins all lines back together.
    [
      # Ignore empty lines in template_json with compact.
      for line in compact(split("\n", local.json_template_file_content)) :
      # Runs a subloop on all replacments, if found, takes the first one from that list, else takes the unmodified line from the list.
      compact(
        # No replacment result in an empty list, which gets removed by compact after flatten.
        flatten([
          [
            for replace_identifier, injection_content in local.final_injection_identifier_to_injection_map :
            replace(line, "/${replace_identifier}/", jsonencode(injection_content))
            if can(regex(replace_identifier, line))
          ], [line]
        ])
      )[0]
    ]
  )

}
