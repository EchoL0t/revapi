include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/address/google//?version=3.2.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}


inputs = {
    project_id   =  "${local.project_id}"
    region = "${local.region}"
    names = ["${local.env}-sapi-nat-ip-01"]
    address_type = "EXTERNAL"
    network_tier = "STANDARD"
}
