terraform {

  required_providers {}

  backend "local" {}
}

locals {
  environment = "dev"
}
