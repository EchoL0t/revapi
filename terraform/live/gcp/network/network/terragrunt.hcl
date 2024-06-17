include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/network/google//?version=8.0.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

inputs = {
    project_id   =  "${local.project_id}"
    network_name = "${local.env}-sapi"
    routing_mode = "REGIONAL"

    subnets = [
        {
            subnet_name           = "${local.env}-sapi-de"
            subnet_ip             = "172.16.99.0/24"
            subnet_region         = "${local.region}"
            subnet_private_access = "true"
        }
    ]
}
