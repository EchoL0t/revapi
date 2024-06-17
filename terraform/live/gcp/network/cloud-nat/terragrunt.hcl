include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/cloud-nat/google//?version=5.0.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

dependency "nat_ips" {
  config_path = "../nat-ips"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
    project_id   =  "${local.project_id}"
    region = "${local.region}"
    name = "${local.env}-sapi"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
      name                     = "${local.env}-sapi-de"
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
      },
    ]
    nat_ips = "${dependency.nat_ips.outputs.self_links}"
    create_router = true
    router = "${local.env}-sapi"
    network = "${dependency.network.outputs.network_name}"
}
