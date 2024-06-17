include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google//?version=4.2.2"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

inputs = {
  project_id    = "${local.project_id}"
  names         = ["${local.env}-vm-account"]
  project_roles = ["${local.project_id}=>roles/viewer"]
  display_name  = "VM Account"
  description   = "Service Account for vm instances"
}
