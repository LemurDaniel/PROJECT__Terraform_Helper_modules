



provider "modtm" {
  enabled = true
  # The endpoint where to send data from CRUD-Operations.
  # In this case some smee.io for quick-testing: https://smee.io
  endpoint = "https://smee.io/Tz0YJOr6dWymTuuQ"
}


/*

  The resources sends on CRUD Operations to the endpoint:

  (
    This is for example added to a module and hosted on terraform.

    Whenever the module is used, the 'modtm_telemetry' gets CREATED, READ, UPDATED or DELETED
  )

  CREATE:   This happens on apply and resource creation.
            For example when the module is first used and all its resources (as well as 'modtm_telemetry') are created.

  READ:     This happens whenever the resource is read by a terraform refresh. 
            For example when performing a terraform plan.

  UPDATE:   This happens whenever the resources is updated. 
            For example the module version gets updated and the maintainer changed the 'modtm_telemetry'-tags for both module-versions.


  DELETE:   This happens whenever the resource is deleted. 
            For exmaple by removing the module or performing 'terraform destroy'.


  A basic request with all data is send to the specifed endpoint on each of these Operations.
  The received request can look like this:

    "1699198484671":{

      # The map of custom tags.
      "avm_git_commit":"2724cc167e90f94ce2511c3fb803400d0a486743"
      "avm_git_file":"main.tf"
      "avm_git_last_modified_at":"2023-06-05 02:21:33"
      "avm_git_org":"Azure"
      "avm_git_repo":"terraform-provider-modtel"

      # Note json-encoded strings are possible.
      "json_encoded":"{"test":"123"}"
      "module_version":"123"

      # These are always send
      "event":"update" # The CRUD-Operation
      "resource_id":"5322d0bb-7e4c-4e42-a21f-6edac650c79b"
    }
*/


# The modtm resource: https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry
resource "modtm_telemetry" "test_1" {

  # This map can contain an key value pair, as long as it is a string or JSON-encoded string.
  tags = {
    module_version = "123"
    json_encoded = jsonencode(
      {
        test = "123"
      }
    )


    avm_git_commit           = "2724cc167e90f94ce2511c3fb803400d0a486743"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-06-05 02:21:33"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-provider-modtel"
  }

  nonce = 12345
  lifecycle {
    ignore_changes = [nonce]
  }
}

# The modtm resource: https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry
resource "modtm_telemetry" "test_2" {

  # This map can contain an key value pair, as long as it is a string or JSON-encoded string.
  tags = {
    module_version = "123"
    json_encoded = jsonencode(
      {
        test = "123"
      }
    )

    avm_git_commit           = "2724cc167e90f94ce2511c3fb803400d0a486743"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-06-05 02:21:33"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-provider-modtel"
  }

  nonce = 12345
  lifecycle {
    ignore_changes = [nonce]
  }
}


# The modtm resource: https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry
resource "modtm_telemetry" "test_3" {

  # This map can contain an key value pair, as long as it is a string or JSON-encoded string.
  tags = {
    module_version = "123"
    json_encoded = jsonencode(
      {
        test = "123"
      }
    )

    avm_git_commit           = "2724cc167e90f94ce2511c3fb803400d0a486743"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-06-05 02:21:33"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-provider-modtel"
  }

  nonce = 12345
  lifecycle {
    ignore_changes = [nonce]
  }
}
