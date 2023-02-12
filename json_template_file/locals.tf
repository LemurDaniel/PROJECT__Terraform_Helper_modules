
locals {

  json_template_file_path_abs  = abspath(format("%s/%s", path.root, var.json_template_file_path))
  json_template_file_directory = join("/", slice(split("/", local.json_template_file_path_abs), 0, length(split("/", local.json_template_file_path_abs)) - 1))

  json_template_file_name      = split("/", local.json_template_file_path_abs)[length(split("/", local.json_template_file_path_abs)) - 1]
  json_template_file_base_name = join(".", slice(split(".", local.json_template_file_name), 0, length(split(".", local.json_template_file_name)) - 1))

  # Read the JSON-File in which certain files will be injected as maps or lists.
  json_template_file_content = file(local.json_template_file_path_abs) # Not JSON-Decoded for injecting later into JSON-String!



  # Gets for any regexmatch, all the files at the filepaths as a map of: { filename => file_content } to replace in the json.
  regex_captures_replace_as_map = {
    # Caputes formats of "{{./some_path}}" => !Inludes Quotations, to replace the whole string with an json-object.
    for replace_identifier in regexall("\"{{[^{}]+}}\"", local.json_template_file_content) :
    replace(
      replace_identifier, "/([\\[\\]\\*])/", "\\$1"
      ) => {
      # The path as an array in the JSON-Template-file.
      file_path_array = split("/", replace(replace_identifier, "/[{}\"]+/", ""))
      injection_type  = "AsMap"
    }
  }

  # Gets for any regexmatch, all the files at the filepaths as a list of: [ file_content ] to replace in the json.
  regex_captures_replace_as_list = {
    # Caputes formats of "[[./some_path]]" => !Inludes Quotations, to replace the whole string with an json-list.
    for replace_identifier in regexall("\"\\[\\[[^\\[\\]]+\\]\\]\"", local.json_template_file_content) :
    replace(
      replace_identifier, "/([\\[\\]\\*])/", "\\$1"
      ) => {
      # The path as an array in the JSON-Template-file.
      file_path_array = split("/", replace(replace_identifier, "/[\\[\\]\"]+/", ""))
      injection_type  = "AsList"
    }
  }


  # Convert all the read values from the JSON-Template to file_path, the file_filter and injection_type
  regex_captures_replace_correct_filepath = {
    for replace_identifier, config in merge(local.regex_captures_replace_as_map, local.regex_captures_replace_as_list) :
    replace_identifier => {
      file_path      = format("%s/%s", local.json_template_file_directory, join("/", slice(config.file_path_array, 0, length(config.file_path_array) - 1)))
      file_filter    = config.file_path_array[length(config.file_path_array) - 1]
      injection_type = config.injection_type
    }
  }

  # Read all files for each replacement with the injection type 'AsMap'
  files_to_inject_as_map = {
    for replace_identifier, config in local.regex_captures_replace_correct_filepath :
    replace_identifier => {
      for file in fileset(config.file_path, config.file_filter) :
      "${split(".", file)[0]}" => jsondecode(file(format("%s/%s", config.file_path, file)))
    }
    if config.injection_type == "AsMap"
  }

  # Read all files for each replacement with the injection type 'AsList'
  files_to_inject_as_list = {
    for replace_identifier, config in local.regex_captures_replace_correct_filepath :
    replace_identifier => [
      for file in fileset(config.file_path, config.file_filter) :
      jsondecode(file(format("%s/%s", config.file_path, file)))
    ]
    if config.injection_type == "AsList"
  }


  files_to_inject_merged = merge(local.files_to_inject_as_map, local.files_to_inject_as_list)

  result_configuration = join("\n",
    # Splits the String into lines and checks on each line for possible replacment, then joins all lines back together.
    [
      for line in split("\n", local.json_template_file_content) :
      # Runs a subloop on all replacments, if found, takes the first one from that list, else takes the unmodified line from the list.
      compact(
        # No replacment result in an empty list, which gets removed by compact after flatten.
        flatten([
          [
            for replace_identifier, injected_values in local.files_to_inject_merged :
            replace(line, "/${replace_identifier}/", jsonencode(injected_values))
            if can(regex(replace_identifier, line))
          ], [line]
        ])
      )[0]
    ]
  )

}
