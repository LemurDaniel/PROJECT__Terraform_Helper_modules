

## Helper-Module: json_template_file

Reads a JSON-File from an location and inserts subsequent files as specified.

### Module Usage:

1. Module Call with the JSON-Template location from the terraform root.
2. Calls the JSON-Decoded File with all dynimcally inserted Values.

```terraform
module "json_template_file" {
  source = "./json_template_file"

  json_template_file_path = format(".config/azure_automation/%s/automation.settings.json", local.environment)

}

output "name" {
  value = module.json_template_file.result_configuration
}

```

## Example for the JSON-File

Normal JSON file with possibility of inserting Files at a Location as a Map or a List.

To append any File as a Map or a List, a string with syntax `'{{./path/files}}'` needs to be specified:
- `'./path'` defines the path based on the location of the JSON-template
- `'files'` defines wich kind of files should be appended

For Example `'{{./azure_vm/windows/*.azure_update_schedule.json}}'` means that from the JSON-Template location:
- => Files in the `'./azure_vm/windows'`-Folder ending with `'*.azure_update_schedule.json'` should be appended as a Map.


Appending a List vs a Map:
- Putting the Path into Curley-Brackets `'{{}}'` creates a Map
- Putting the Path into Square-Brackets `'[[]]'` creates a List

Note:
  - Allows only for one insertion per line in the JSON-File.
  - Meaning all insertions need to be seperated by linebreaks and can't be compressed into a single one-line-JSON-String:
    - "windows": "{{./azure_vm/windows/*.azure_update_schedule.json}}",
    - "linux": "{{./azure_vm/linux/*.azure_update_schedule.json}}"

```JSON
{
    "name": "automation",
    "resource_group_name": "automationaccount",
    "log_analytics_linked_service": true,
    "azurevm_config": {
        "schedule_trigger_version": 1,
        "subscriptions": [
            "",
            ""
        ],
        "scheduled_updates_configurations": {
            "windows": "{{./azure_vm/windows/*.azure_update_schedule.json}}",
            "linux": "{{./azure_vm/linux/*.azure_update_schedule.json}}"
        }
    },
    "nonazurevm_config": {
        "enabled": true,
        "schedule_trigger_version": 4,
        "schedule_defaults": "{{./non_azure_vm/schedule_defaults/*.schedule_default.json}}",
        "schedule_definitions": "[[./non_azure_vm/schedule_definitions/*.schedule_definition.json]]"
    },
    "monitoring_config": {
        "enable_alerts": true,
        "enable_default_alert_configuration": true,
        "action_groups": [],
        "custom_metric_alerts": {},
        "custom_log_alerts": {}
    }
}

```

