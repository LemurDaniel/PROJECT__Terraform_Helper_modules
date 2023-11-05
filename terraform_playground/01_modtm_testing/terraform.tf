

terraform {
    required_version = "1.5.5"

    required_providers {
      modtm = {
        source = "Azure/modtm"
        version = "0.1.8"
      }
    }

    backend "local" {}
}